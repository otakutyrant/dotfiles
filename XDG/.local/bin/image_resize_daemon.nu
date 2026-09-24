#!/usr/bin/env nu
# Image Resize Daemon
#
# Watches only the top level of /home/otakutyrant by default and resizes
# supported image files in place when their shortest side is less than 800px.
#
# Image work is delegated to Imageflow. Nushell handles polling, file state
# tracking, and systemd-friendly logging.
#
# Supported formats:
# - JPEG
# - PNG
# - WebP
# Imageflow can encode JPEG, PNG, and WebP, so other extensions are ignored.
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
def resize-image [path: string, target_short_side: int] {
    let parsed = ($path | path parse)
    let parent = ($path | path dirname)
    let suffix = if ($parsed.extension | is-empty) {
        ".img"
    } else {
        $".($parsed.extension)"
    }
    let extension = ($parsed.extension | str downcase)
    let preset = if $extension in [jpg, jpeg] {
        {mozjpeg: {quality: 90, progressive: false}}
    } else if $extension == "png" {
        {lodepng: {maximum_deflate: false}}
    } else {
        {webplossy: {quality: 90}}
    }
    let temp_path = (mktemp --tmpdir-path $parent --suffix $suffix $".($parsed.stem)-XXXXXX")
    let job_path = (mktemp --suffix .json image-resize-job-XXXXXX)
    let job = {
        io: [
            {io_id: 0, direction: "in", io: "placeholder"}
            {io_id: 1, direction: "out", io: "placeholder"}
        ]
        framewise: {
            steps: [
                {decode: {io_id: 0}}
                {constrain: {mode: "larger_than", w: $target_short_side, h: $target_short_side}}
                {encode: {io_id: 1, preset: $preset}}
            ]
        }
    }
    ($job | to json) | save --force $job_path
    let result = (do {
        ^imageflow_tool v1/build --json $job_path --in $path --out 1 $temp_path
    } | complete)
    rm --force $job_path
    if $result.exit_code != 0 {
        rm --force $temp_path
        return {ok: false, reason: ($result.stderr | str trim)}
    }
    let operation = try {
        $result.stdout
        | from json
        | get data.build_result
    } catch {
        rm --force $temp_path
        return {ok: false, reason: $"unexpected Imageflow response: ($result.stdout | str trim)"}
    }
    let decoded = ($operation.decodes | first)
    let source_short_side = ([$decoded.w, $decoded.h] | math min)
    if $source_short_side >= $target_short_side {
        rm --force $temp_path
        return {ok: true, resized: false, reason: ""}
    }
    let encoded = ($operation.encodes | first)
    let output_short_side = ([$encoded.w, $encoded.h] | math min)
    if $output_short_side < $target_short_side {
        rm --force $temp_path
        return {ok: false, reason: $"Imageflow left the short side at ($output_short_side)px"}
    }
    mv --force $temp_path $path
    {ok: true, resized: true, reason: ""}
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
        let resized = (resize-image $path $target_short_side)
        if not $resized.ok {
            log-message WARNING $"Failed to resize ($path): ($resized.reason)"
            $known_states = ($known_states | upsert $path $state)
            continue
        }
        if not $resized.resized {
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
