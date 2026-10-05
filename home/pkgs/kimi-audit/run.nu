#!/usr/bin/env nu
# Keep the entry point usable from Nushell and systemd without shell profiles.
def --wrapped main [runtime: path, ...args: string] {
    let config = open $runtime
    ^($config.bins.python3) ($config.scripts | path join tasks.py) $runtime ...$args
    exit $env.LAST_EXIT_CODE
}
