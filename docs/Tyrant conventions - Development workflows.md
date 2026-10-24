This is a Tyrant convention.

# Development workflows and Panoptor

## Task catalog

Keep the root `nurfile` small and split a growing catalog into focused Nushell
modules. A task is important when it is a common entrypoint, composes commands,
prepares state, controls a long-running process, or preserves ordering,
cleanup, safety, or environment boundaries.

Provide applicable focused commands for formatting, linting, type checking,
architecture, tests, licenses, vulnerabilities, builds, frameworks, generated
code, databases, and deployment. Add safe preferably idempotent setup; named
test suites with their environments/services; runtime readiness and lifecycle
wrappers; a non-mutating one-shot doctor; subsystem composites; and one normal
mechanical validation entrypoint.

Direct tasks stay thin and expose native output/failure. Composites call focused
tasks rather than repeating command lines. Preserve intentional fail-fast order:
diagnostics and tests precede mutating formatting. Keep semantic, networked,
costly, destructive, and deployment workflows explicit.

Do not manufacture categories a small repository does not need. The task
runner's listing/help surface is the live command catalog; do not duplicate it
in `AGENTS.md`.

## Watches

Use Process Compose native `watch` blocks for Panoptor roles when the selected
version supports them. Keep each Nur command one-shot so Process Compose owns
file observation, debouncing, reruns, status, logs, and lifecycle. Preserve a
non-watching Nur command for automation.

Choose narrow roots and include/exclude patterns from repository evidence.
Exclude large project-local state trees that the orchestrator's defaults do
not cover. Verify that every configured watch actually arms; schema validation
alone does not detect exhausted watcher limits or unsuitable roots. A failed
one-shot must remain visibly failed while its watch stays armed so the next edit
can recover it.

Use a tool's native development watcher only where it is intrinsic to the
framework server (for example, HMR). Avoid wrapping validation commands in
language-specific watchers underneath Process Compose because that obscures
real process state and shutdown behavior.

## Panoptor

Panoptor is a persistent, language-agnostic Process Compose session for useful
validation watches, servers, workers, local services, and runtime health. Every
process invokes a Nur task; Process Compose does not own command implementation.

Start headlessly by default and attach the TUI on demand. Attaching must not
start duplicate roles, detaching must leave the session running, and stopping
must terminate roles and the server. Keep headless composite workflows usable;
Panoptor is not the only validation path.

Make the repository instruction contract tell main-worktree agents how to use
the resulting topology. When a suitable Panoptor role exists, they first check
for the session and use its task-runner controls to inspect current state,
readiness, and bounded output and to freshly rerun or restart the affected role.
They do not launch duplicate standalone watchers or services. Standalone
one-shot tasks remain appropriate when the session is absent, no role covers
the check, or a prescribed deterministic composite requires them. A role's
running or previously successful state is not evidence for the current tree;
rerun it when the result may predate relevant changes.

Define stable role names plus applicable startup dependencies, readiness
probes, restart policy, scheduled checks, and shutdown behavior. Distinguish
readiness from liveness. Do not hide crash loops with unconditional restart;
select restart behavior deliberately for each role.

Expose focused task-runner controls that can:

- list roles and distinguish running, watching, failed, completed, pending,
  scheduled, and unknown states;
- attach/detach without lifecycle changes;
- fetch bounded recent output;
- start, stop, restart, and freshly rerun one role;
- report readiness separately from process liveness; and
- regenerate state and recover one role or the full topology after environment
  changes.

Keep Process Compose behind Nur. Prefer a private Unix socket and runtime state
outside the repository. Return useful failures for absent sessions or roles.
Do not treat a running process as proof that its latest validation passed.

## Topology

Decide topology in planning. Prefer one isolated Panoptor per worktree only when
ports, sockets, directories, databases, generated artifacts, and other mutable
resources can be isolated and machine capacity is sufficient. Record the
isolation and resource expectation.

Otherwise choose a main-worktree singleton. Guard its control commands and tell
linked-worktree agents not to start/control it or claim its live validation.
Integrate their changes in the main worktree before using the singleton.

## Validation

Use the pinned Process Compose version's authoritative schema and CLI help.
Validate the configuration, command discovery, headless startup, structured
list output, bounded logs, TUI attach/detach, shutdown, and recovery. Exercise
at least one one-shot watch through a real file event and one long-running
server through stop/start/restart. Confirm dependencies and readiness with live
state, and stop the validation session unless the user asked to leave it
running.

## Project deviations

None.
