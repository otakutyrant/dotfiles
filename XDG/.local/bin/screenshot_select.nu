#!/usr/bin/env nu
def main [
  --delay: duration = 0sec # Wait before starting the selection.
  --full-screen (-f) # Capture the whole screen instead of selecting a region.
  --geometry (-g): string # Capture a fixed geometry, such as 600x180+20+30.
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
    let selected_geometry = if $geometry != null {
        $geometry
    } else if $full_screen {
        null
    } else {
        # `hacksaw` provides the drag-to-select UI; Escape cancels without
        # taking a screenshot. `shotgun` performs the actual X11 capture.
        try {
            ^hacksaw | str trim
        } catch {
            exit 0
        }
    }
    if $selected_geometry != null {
        ^shotgun --geometry $selected_geometry --format png $file
    } else {
        ^shotgun --format png $file
    }
    if not ($file | path exists) {
        exit 0
    }
    ^clipcatctl load --mime image/png --file $file
    notify-send -a screenshot_select.nu -i $file "Screenshot saved" $file
}
