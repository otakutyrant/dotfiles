#!/usr/bin/env nu
# Image Resize Daemon
#
# Watches only the top level of /home/otakutyrant by default and resizes
# supported image files in place when their shortest side is less than 800px.
#
# Image work is delegated to ImageMagick. Nushell handles polling, file state
# tracking, and systemd-friendly logging.
#
# Supported formats:
# - JPEG
# - PNG
# - WebP
# - BMP
# - TIFF
#
# Notes:
# - Aspect ratio is preserved.
# - Images whose shortest side is already greater than or equal to 800px are
#   left untouched.
# - Multi-frame images are skipped.
# - Subdirectories are ignored completely; the scan is not recursive.
#
# Run one scan:
#   /home/otakutyrant/.local/bin/image_resize_daemon.nu --once
#
# Run continuously:
#   /home/otakutyrant/.local/bin/image_resize_daemon.nu
#
# Install as a user service through Home Manager:
#   home-manager switch --flake .#otakutyrant
#   systemctl --user daemon-reload
#   systemctl --user restart image-resize-daemon.service
#
# Check logs:
#   journalctl --user -u image-resize-daemon.service -f
const SUPPORTED_EXTENSIONS = [
    jpg
    jpeg
    png
    webp
    bmp
    tif
    tiff
]
def log-message [level: string, message: string] {
    let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S")
    print $"($timestamp) ($level) ($message)"
}
def file-state [path: string] {
    let row = (ls $path | first)
    {
        size: ($row.size | into int)
        modified: ($row.modified | format date "%s%f")
    }
}
def is-supported-image [path: string] {
    let extension = (
        $path | path parse | get extension | str downcase
    )
    $extension in $SUPPORTED_EXTENSIONS
}
def image-info [path: string] {
    let result = (do { ^magick identify -format "%m\t%w\t%h\n" -- $path } | complete)
    if $result.exit_code != 0 {
        return {
            ok: false
            reason: ($result.stderr | str trim)
        }
    }
    let frames = ($result.stdout | lines)
    if ($frames | length) != 1 {
        return {ok: false, reason: "multi-frame image"}
    }
    let fields = ($frames | first | split row "\t")
    if ($fields | length) != 3 {
        return {
            ok: false
            reason: $"unexpected identify output: ($result.stdout | str trim)"
        }
    }
    {
        ok: true
        format: ($fields | get 0)
        width: ($fields | get 1 | into int)
        height: ($fields | get 2 | into int)
    }
}
def resize-image [path: string, target_short_side: int, format: string] {
    let parsed = ($path | path parse)
    let parent = ($path | path dirname)
    let suffix = if ($parsed.extension | is-empty) {
        ".img"
    } else {
        $".($parsed.extension)"
    }
    let temp_path = (mktemp --tmpdir-path $parent --suffix $suffix $".($parsed.stem)-XXXXXX")
    let resize_geometry = $"($target_short_side)x($target_short_side)^"
    let format_name = ($format | str upcase)
    let result = if ($format_name in [JPEG, JPG]) {
        do {
            ^magick $path -auto-orient -resize $resize_geometry -quality 90 $temp_path
        } | complete
    } else if $format_name == "PNG" {
        do {
            ^magick $path -auto-orient -resize $resize_geometry -define png:compression-level=9 $temp_path
        } | complete
    } else {
        do {
            ^magick $path -auto-orient -resize $resize_geometry $temp_path
        } | complete
    }
    if $result.exit_code == 0 {
        mv --force $temp_path $path
        return {ok: true, reason: ""}
    }
    rm --force $temp_path
    {
        ok: false
        reason: ($result.stderr | str trim)
    }
}
def scan-once [
    root: string
    target_short_side: int
    known: record
    recently_resized: record
    verbose: bool
] {
    mut known_states = $known
    mut resized_states = $recently_resized
    mut current_paths = []
    for entry in (ls --all $root | where type == file) {
        let path = $entry.name
        if not (is-supported-image $path) {
            continue
        }
        $current_paths = ($current_paths | append $path)
        let state = (file-state $path)
        if ($known_states | get --optional $path) == $state {
            continue
        }
        if ($resized_states | get --optional $path) == $state {
            $known_states = ($known_states | upsert $path $state)
            continue
        }
        let info = (image-info $path)
        if not $info.ok {
            if $verbose {
                log-message DEBUG $"Skipping ($path): ($info.reason)"
            } else if $info.reason != "multi-frame image" {
                log-message WARNING $"Skipping unreadable image ($path): ($info.reason)"
            }
            $known_states = ($known_states | upsert $path $state)
            continue
        }
        let short_side = ([
            $info.width
            $info.height
        ] | math min)
        if $short_side >= $target_short_side {
            $known_states = ($known_states | upsert $path $state)
            continue
        }
        let resized = (resize-image $path $target_short_side $info.format)
        if not $resized.ok {
            log-message WARNING $"Failed to resize ($path): ($resized.reason)"
            $known_states = ($known_states | upsert $path $state)
            continue
        }
        let new_state = (file-state $path)
        $known_states = ($known_states | upsert $path $new_state)
        $resized_states = ($resized_states | upsert $path $new_state)
        log-message INFO $"Resized ($path)"
    }
    for path in ($known_states | columns) {
        if $path not-in $current_paths {
            $known_states = ($known_states | reject $path)
            if ($resized_states | columns | any {|saved_path| $saved_path == $path }) {
                $resized_states = ($resized_states | reject $path)
            }
        }
    }
    {
        known: $known_states
        recently_resized: $resized_states
    }
}
def main [
    --root: string = /home/otakutyrant
    --target-short-side: int = 800
    --interval: int = 5
    --once
    --verbose
] {
    if $target_short_side <= 0 {
        log-message ERROR "--target-short-side must be greater than zero"
        exit 2
    }
    if $interval <= 0 {
        log-message ERROR "--interval must be greater than zero"
        exit 2
    }
    let resolved_root = ($root | path expand)
    if not ($resolved_root | path exists) {
        log-message ERROR $"Root path does not exist: ($resolved_root)"
        exit 2
    }
    mut state = {
        known: {}
        recently_resized: {}
    }
    if $once {
        $state = (scan-once $resolved_root $target_short_side $state.known $state.recently_resized $verbose)
        exit 0
    }
    log-message INFO $"Watching ($resolved_root) for images whose shortest side is below ($target_short_side)px"
    loop {
        $state = (scan-once $resolved_root $target_short_side $state.known $state.recently_resized $verbose)
        sleep ($interval * 1sec)
    }
}
