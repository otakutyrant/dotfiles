#!/tools/nu
def --wrapped main [...args: string] {
    # Shell tools cannot reach even the model broker's loopback bridge.
    let runtime = open /audit/runtime.json
    ^bwrap --unshare-net --die-with-parent --ro-bind / / --tmpfs /gateway -- $runtime.bins.bash ...$args
    exit $env.LAST_EXIT_CODE
}
