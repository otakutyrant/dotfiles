#!/usr/bin/env nu

def main [
    --delay: duration = 0sec # Wait before opening the region selector.
    --full-screen (-f) # Capture the focused output instead of selecting a region.
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
        ^wayshot $file
    } else {
        try {
            ^wayshot $file -g
        } catch {
            exit 0
        }
    }
    ^wl-copy --type image/png < $file
}
