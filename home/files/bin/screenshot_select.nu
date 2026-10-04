#!/usr/bin/env nu

def visible-window-boxes [node: record] {
    # Floating windows must come first because WaySip picks the first matching
    # rectangle, and a floating window can overlap a tiled one.
    let floating = try { $node.floating_nodes } catch { [] }
    let tiled = try { $node.nodes } catch { [] }
    let own = try {
        if $node.visible and $node.pid != null and $node.rect.width > 0 and $node.rect.height > 0 {
            [$"($node.rect.x),($node.rect.y) ($node.rect.width)x($node.rect.height)"]
        } else {
            []
        }
    } catch {
        []
    }

    $floating
    | append $tiled
    | reduce --fold $own { |child, boxes| $boxes | append (visible-window-boxes $child) }
}

def main [
    --delay: duration = 0sec # Wait before opening the region selector.
    --full-screen (-f) # Capture all connected outputs without opening a selector.
    --window (-w) # Select one of Sway's visible windows.
] {
    if $delay > 0sec {
        sleep $delay
    }

    let picture_dir = try {
        ^xdg-user-dir PICTURES
    } catch {
        $env.HOME | path join Pictures
    }
    let dir = $env.XDG_SCREENSHOT_DIR? | default ($picture_dir | path join Screenshots)
    mkdir $dir | ignore
    let file = $dir | path join $"(date now | format date '%Y-%m-%d_%H-%M-%S').png"
    if $full_screen {
        # Wayshot's actionable notification forks a listener that retains
        # Nushell's stdout pipe, so keep this wrapper's capture noninteractive.
        ^wayshot --silent $file
    } else {
        let geometry = try {
            if $window {
                let tree = ^swaymsg -t get_tree -r | from json
                let boxes = visible-window-boxes $tree
                if ($boxes | is-empty) {
                    exit 0
                }
                $boxes | str join (char newline) | ^waysip -r
            } else {
                # Combined mode captures an output with one click or an
                # arbitrary region by dragging.
                ^waysip -d -o
            }
        } catch {
            exit 0
        }
        try {
            ^wayshot --silent $file -g $geometry
        } catch {
            exit 0
        }
    }
    # Pipe the PNG bytes; Nushell treats `< $file` as literal arguments.
    open --raw $file | ^wl-copy --type image/png
}
