# Reusable Kimi project audits

`kimi-audit` runs one project audit at a time. The Home Manager module at
`home/options/services/kimi-audit.nix` installs this package and its user timer.
No project or source revision is hard-coded in the service.

```nu
kimi-audit quota
kimi-audit start ~/Projects/example
kimi-audit status
kimi-audit pause
kimi-audit resume
kimi-audit cancel
```

`start` snapshots the project, selects a new task, and starts the service.
An unfinished task (including a paused or blocked task) prevents another start.
Complete or cancel it first. Cancelling preserves its source, session and logs.
Each task gets a separate Kimi home, and automatic retries resume that task's
session. Editing the original project after submission does not change it.

For a non-Git directory, explicitly select its regular files:

```nu
kimi-audit start ~/tmp/source-archive --all-files
kimi-audit start ~/Projects/example --instructions ~/tmp/audit-focus.txt
```

Git mode includes tracked **working-tree contents**, including modifications;
untracked and ignored files are absent. Plain-directory mode includes regular
files recursively. Neither mode follows symlinks; submodules need separate
audits. Both omit `.git`, `.hg`, `.svn`, `node_modules`, `.venv`, `venv`,
`__pycache__`, `.direnv`, and filenames starting with `.env`. Files over 10 MiB
and special, missing or changing files are omitted. A task is limited to
100,000 candidate files and 500 MiB. These exclusions are not a secret scanner:
submit source that you are willing to send to Kimi. Normal configuration files
and other tracked files remain eligible for the model to inspect.

To inspect the snapshot before allowing any model calls:

```nu
kimi-audit start ~/Projects/example --prepare-only
let task = kimi-audit status --json | from json
open ($task.directory | path join manifest.json)
kimi-audit probe
kimi-audit resume
```

`manifest.json` lists included paths with SHA-256 hashes and file omissions.
The probe makes no model requests and leaves a prepared task paused. Project
symlink directories and excluded cache directories are not traversed, so their
descendants are not enumerated in the manifest. The snapshot is read-only
inside Bubblewrap. Only runtime dependencies and the task's private home/output
are also visible. Host credentials, other projects and external networking are
not exposed. Shell tools enter a further network namespace without the broker.
The host-only broker can contact only the fixed Kimi model endpoint; it adds
credentials outside the sandbox and refuses redirects and arbitrary proxying.
The prompt requests static inspection only and treats project instructions as
untrusted. This does not prove that every excerpt selected by the model is
necessary for the audit.

## Quota and retry behavior

`kimi-audit quota` reads Kimi's usage endpoint without inference. It works with
no selected task and does not start, resume or change an audit. It displays
five-hour and weekly used percentages and reset times, plus monthly limits
when supplied. `available`, `exhausted`, and `unknown` distinguish actual quota
from authentication/network failures. `--json` is available on every command:

```nu
kimi-audit quota --json | from json
kimi-audit status --json | from json
```

An exhausted quota is a successful status query (exit 0); unknown availability
exits 1. Inspect the `status` field in scripts, not just the exit code.
The service checks quota before every model request. Both quota windows must
be available; when several are exhausted it waits for the latest reset plus
one minute. It does not intentionally use booster credit to bypass exhaustion.
The endpoint cannot reserve capacity against another client or stop an ongoing
request from crossing a quota threshold.

Existing `~/.kimi-code/credentials/kimi-code.json` credentials are used and
refreshed if needed, including for quota checks. Credentials never enter the
Nix store or sandbox. Refresh coordinates with Kimi's native lock and writes
tokens atomically with mode 0600. A stale-looking lock is not stolen; inspect
normal Kimi processes if status remains `oauth-refresh-lock-busy`.

Authentication errors pause requests until credentials change (normally after
`kimi login`). Other CLI/configuration errors require inspection and an explicit
`resume`. Resume preserves a saved quota delay. Network failures wait at least
15 minutes; HTTP 429 uses Retry-After or a one-hour fallback. Eight successful
but unfinished turns block further automatic continuation. Completion requires
a successful Kimi exit, a session resume hint, and a final assistant report
ending with `AUDIT_COMPLETE`. Further timer ticks then make no model requests.

## State and service

Tasks live in `$XDG_STATE_HOME/kimi-audit/jobs/<id>/`, normally
`~/.local/state/kimi-audit/jobs/<id>/`. Each contains `task.json`, `status.json`,
the source snapshot and manifest, its session, private logs and, on completion,
`REPORT.md`. `status` shows the selected task and report path. Previous task
directories remain available after selecting another project.

Completion sends one desktop notification through `notify-send`, showing the
project name, report path and a report link (if the desktop supports links).
The notification stays until dismissed where supported. Delivery is recorded
in each task's `notification.json`, so later timer ticks and restarts do not
repeat it. A failed delivery is retried on a later tick, even after another
project is selected. No model tokens are used for notifications. A crash during
delivery or a timeout leaves `sending`/`uncertain`: these are not automatically
retried because the desktop may already have displayed the alert. Desktop
notifications cannot provide a transactional exactly-once delivery guarantee.

```nu
systemctl --user status kimi-audit.timer kimi-audit.service
journalctl --user -u kimi-audit.service -n 30
```

The timer runs every 15 minutes while the user systemd manager is active.
Saved reset times suppress premature checks. No task, a pause, cancellation or
completion makes a timer tick a no-op. User lingering is not enabled by this
package. The old Codex report and session remain at
`~/.local/state/kimi-codex-audit/`; the old timer is disabled during migration.

The Nushell entry point delegates HTTP/process management to Python's standard
library. `tasks.py` owns task selection/snapshots, `supervisor.py` owns execution,
and `host_api.py` owns OAuth/usage. `inside.py` and `offline-shell.nu` are the
only executable helpers mounted inside the sandbox. Kimi's protocol was checked
against packaged version 2.0.2; revalidate when upgrading Kimi.

Run `nur test-kimi-audit` for offline tests, then `nur check` for repository
checks. Live sandbox testing can use the prepared-task probe above; no model
tokens are needed to test snapshots, scheduling, isolation or quota status.
