#!/usr/bin/env nu

# Reveal Yihui's persistent Panoptor session, starting it only when absent.
const PROJECT_ROOT = "/home/otakutyrant/Projects/ci"

def session-address []: nothing -> string {
    let runtime_directory = $env.XDG_RUNTIME_DIR? | default null
    if $runtime_directory == null {
        error make { msg: "XDG_RUNTIME_DIR is required to locate Yihui Panoptor." }
    }
    $"unix:($runtime_directory)/yihui-nur.sock"
}

def remote [address: string arguments: list<string>]: nothing -> record {
    ^kitten @ --to $address ...$arguments | complete
}

let address = session-address
if (remote $address [ls]).exit_code != 0 {
    let started = (^direnv exec $PROJECT_ROOT nur session | complete)
    if $started.exit_code != 0 {
        error make { msg: ($started.stderr | str trim) }
    }
}

let shown = remote $address [resize-os-window --match all --action show --no-response]
if $shown.exit_code != 0 {
    error make { msg: ($shown.stderr | str trim) }
}
