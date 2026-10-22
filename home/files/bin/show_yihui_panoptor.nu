#!/usr/bin/env nu

# Focus Yihui's Process Compose TUI, starting the headless session only when absent.
const PROJECT_ROOT = "/home/otakutyrant/Projects/ci"
const APP_ID = "yihui-panoptor"

def project-command [arguments: list<string>]: nothing -> record {
    ^direnv exec $PROJECT_ROOT nur ...$arguments | complete
}

def focus-existing-window []: nothing -> bool {
    let result = (^swaymsg $"[app_id=\"($APP_ID)\"] focus" | complete)
    if $result.exit_code != 0 {
        return false
    }
    let replies = try {
        $result.stdout | from json
    } catch {
        []
    }
    $replies | any {|reply| $reply.success? | default false }
}

if not (focus-existing-window) {
    if (project-command [panoptor list --json]).exit_code != 0 {
        let started = project-command [panoptor start]
        if $started.exit_code != 0 {
            error make {
                msg: (($started.stdout + $started.stderr) | str trim)
            }
        }
    }

    ^kitty --class $APP_ID --title "Yihui Panoptor" direnv exec $PROJECT_ROOT nur panoptor attach
}
