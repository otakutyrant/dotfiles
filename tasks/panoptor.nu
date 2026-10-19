# Process Compose-backed control surface for one worktree's validation roles.
# nu-lint-ignore-file: dont_mix_different_effects, missing_output_type
# nu-lint-ignore-file: print_and_return_data, unhandled_external_error

const PROJECT_ROOT = path self | path dirname | path dirname
const CONFIG_PATH = $PROJECT_ROOT | path join process-compose.yaml
const PROJECT_NAME = "dotfiles"

def repository-root []: nothing -> string {
    let result = ^git -C $PROJECT_ROOT rev-parse --show-toplevel | complete
    if $result.exit_code != 0 {
        error make {msg: ($result.stderr | str trim)}
    }
    $result.stdout | str trim | path expand
}

def worktree-id []: nothing -> string {
    repository-root | hash sha256 | str substring 0..11
}

def runtime-directory []: nothing -> string {
    let base = $env.XDG_RUNTIME_DIR? | default null
    if $base == null {
        error make {msg: "XDG_RUNTIME_DIR is required for Panoptor's private runtime state."}
    }
    $base | path join $PROJECT_NAME $"panoptor-(worktree-id)"
}

def socket-path []: nothing -> string {
    runtime-directory | path join process-compose.sock
}

def client-log-path []: nothing -> string {
    runtime-directory | path join client.log
}

def server-log-path []: nothing -> string {
    runtime-directory | path join server.log
}

def prepare-runtime-directory [] {
    let directory = runtime-directory
    mkdir $directory
    ^chmod 700 $directory
}

def --wrapped client-result [...arguments: string]: nothing -> record {
    ^process-compose --use-uds --unix-socket (socket-path) --log-file (client-log-path) ...$arguments | complete
}

def require-session [] {
    if (client-result process list --output json).exit_code != 0 {
        error make {msg: "No dotfiles Panoptor session is running.", help: "Run `nur panoptor start`."}
    }
}

def process-state [role: string]: nothing -> string {
    let listing = client-result process list --output json
    if $listing.exit_code != 0 {
        error make {msg: "Could not read Panoptor process state.", help: ($listing.stderr | str trim)}
    }
    let processes = try { $listing.stdout | from json } catch {
        error make {msg: "Process Compose returned invalid JSON process state."}
    }
    let process = $processes | where name == $role | get --optional 0
    if $process == null {
        error make {msg: $"Unknown Panoptor role '($role)'.", help: "Run `nur panoptor list`."}
    }
    # The pinned nu-lint parser still recognizes the pre-0.114 spelling.
    $process.status? | default unknown | into string | str downcase
}

def run-role-action [action: string role: string] {
    require-session
    let actual_action = if $action == rerun {
        let state = process-state $role
        if $state in [running ready launching pending] { "restart" } else { "start" }
    } else {
        $action
    }
    if $actual_action not-in [start stop restart] {
        error make {msg: "Role action must be 'start', 'stop', 'restart', or 'rerun'."}
    }
    let result = client-result process $actual_action $role
    if $result.exit_code != 0 {
        error make {msg: $"Could not ($actual_action) Panoptor role '($role)'.", help: (($result.stdout + $result.stderr) | str trim)}
    }
    print $"($role): ($actual_action) requested."
}

def start-panoptor [] {
    prepare-runtime-directory
    let socket = socket-path
    if (client-result process list --output json).exit_code == 0 {
        error make {msg: "Dotfiles Panoptor is already running.", help: "Run `nur panoptor list` or `nur panoptor attach`."}
    }
    if ($socket | path exists) {
        rm --force $socket
    }
    let started = with-env {PANOPTOR_PROJECT_ROOT: (repository-root)} {
        ^process-compose --use-uds --unix-socket $socket --log-file (server-log-path) --ordered-shutdown up --config $CONFIG_PATH --detached --tui=false --disable-dotenv --keep-project | complete
    }
    if $started.exit_code != 0 {
        error make {msg: "Process Compose could not start dotfiles Panoptor.", help: (($started.stdout + $started.stderr) | str trim)}
    }
    for _ in 1..40 {
        if (client-result process list --output json).exit_code == 0 {
            print $"Dotfiles Panoptor started for worktree (worktree-id)."
            return
        }
        sleep 250ms
    }
    error make {msg: "Panoptor did not open its control socket.", help: $"Inspect (server-log-path)."}
}

def stop-panoptor [] {
    require-session
    let stopped = client-result down
    if $stopped.exit_code != 0 {
        error make {msg: "Process Compose could not stop dotfiles Panoptor.", help: (($stopped.stdout + $stopped.stderr) | str trim)}
    }
    print "Dotfiles Panoptor stopped."
}

# Validate the checked-in Process Compose graph without starting its roles.
export def "nur panoptor check" [] {
    with-env {PANOPTOR_PROJECT_ROOT: (repository-root)} {
        ^process-compose up --config $CONFIG_PATH --dry-run --disable-dotenv --tui=false
    }
}

# Start this worktree's validation topology headlessly.
export def "nur panoptor start" [] {
    start-panoptor
}

# Stop this worktree's roles and Process Compose server.
export def "nur panoptor stop" [] {
    stop-panoptor
}

# Attach the TUI without changing the session lifecycle.
export def "nur panoptor attach" [] {
    prepare-runtime-directory
    require-session
    ^process-compose --use-uds --unix-socket (socket-path) --log-file (client-log-path) attach
}

# List role liveness and readiness, optionally as JSON.
export def "nur panoptor list" [--json] {
    prepare-runtime-directory
    require-session
    let output = if $json { "json" } else { "wide" }
    ^process-compose --use-uds --unix-socket (socket-path) --log-file (client-log-path) process list --output $output
}

# Print a bounded tail from one role's log buffer.
export def "nur panoptor output" [role: string --tail: int = 100] {
    prepare-runtime-directory
    require-session
    if $tail < 1 {
        error make {msg: "--tail must be a positive line count."}
    }
    ^process-compose --use-uds --unix-socket (socket-path) --log-file (client-log-path) process logs $role --tail $tail
}

# Start, stop, restart, or freshly rerun one role.
export def "nur panoptor role" [action: string role: string] {
    prepare-runtime-directory
    run-role-action $action $role
}

# Recover one role, or restart the complete worktree topology.
export def "nur panoptor recover" [role?: string] {
    prepare-runtime-directory
    if $role == null {
        stop-panoptor
        start-panoptor
    } else {
        run-role-action rerun $role
    }
}
