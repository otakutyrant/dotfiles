Revision: 7

These shared workflow rules apply to the responsibilities and tools selected for
the project. Follow the project facts and approved exceptions in `AGENTS.md`;
skip rules for tools or responsibilities the project does not use. Keep
executable tasks and their usage guidance in `nurfile`.

# Development environment

Define the selected development environment in `flake.nix` and preserve its
committed `flake.lock`; update pinned inputs only when the task requires it.
Provide the selected runtimes, package managers, Nur, and standalone development
tools through the default Nix development shell. Keep ecosystem-managed tools
with their package manager as described below.

Create a root `.envrc` containing `use flake` when it is missing, and keep it
under version control. When it already exists, preserve additional required
directives and add the flake entry only if missing. Use nix-direnv to cache the
development environment. Keep secrets and local runtime state out of tracked
environment files; load application-specific variables through their owning
tasks when needed.

For every project whose resolved repository path is under `~/Projects/`,
automatically authorize and load its `.envrc`. Run `direnv allow .` when needed,
including after intentional `.envrc` changes, without asking the user to repeat
this authorization or separately confirm project ownership. This directory-wide
authorization follows the workspace policy that keeps untrusted repositories
under `~/tmp/` and runs their agents inside the trusted sandbox. It does not
extend to repositories outside `~/Projects/`. Keep `direnv allow` out of Nur
tasks and CI; it authorizes the local environment loader rather than defining a
project task.

The interactive shell's direnv integration loads the environment automatically.
For non-interactive commands whose environment has not been loaded, use
`direnv exec . nur <task>` from the repository root. Avoid nesting `nix develop`
inside an already loaded environment. Verify that the selected tools resolve
from the intended environment before validation. If nix-direnv reports a failed
evaluation and falls back to an older cached environment, resolve or report that
failure; do not treat the fallback as validation of the current flake.

# Tool installation and configuration

Determine check coverage from actual source files, not filename extensions
alone. Include applicable extensionless scripts identified by their shebangs or
tool configuration. For templates that become valid source only after
substitution or generation, check the output of their owning generation process
without executing scripts or loading private runtime environments. Keep Panoptor
watches aligned with those sources and the configuration that affects their
generated output.

Install ecosystem tools through their package manager and language-agnostic
executables through the development environment. If the selected package manager
does not distribute a standalone tool, put it in the approved Nix environment.
Do not choose a weaker tool merely to share an installer. Update the affected
manifests and lockfiles when installing or changing tools.

Keep approved sh/Bash exceptions narrow and justified. The Bash-ban checker
accepts `# no-bash-allow: <reason>` immediately before an embedded shell
interface. A required standalone shell script may use
`# no-bash-script-allow: <reason>` within its first three lines; record the
approved interface and reason in `AGENTS.md` as well. These markers do not
authorize new exceptions by themselves.

For tools in the TypeScript ecosystem, use a `*.ts` configuration entrypoint
whenever the tool and selected runtime support one. Prefer the tool's canonical
`<tool>.config.ts` name, and migrate JavaScript, JSON, or YAML configuration
without losing unrelated settings. Required manifests and compiler-owned files
that have no TypeScript form, such as `package.json` and `tsconfig.json`, are
exceptions.

## Markdown formatting

When Prettier is selected for Markdown, install it through the development
environment and merge this entry into the `overrides` array of the Prettier
configuration resolved from the owning project root:

```ts
{
  files: "*.md",
  options: {
    printWidth: 80,
    proseWrap: "always",
  },
}
```

Preserve imports, plugins, unrelated options, language-specific settings, and
existing overrides. Consolidate overlapping Markdown overrides so these
canonical values win only for Markdown. Use `prettier.config.ts` whenever the
selected runtime can load TypeScript configuration; replace an existing JSON,
YAML, JavaScript, or differently named Prettier configuration without losing its
settings. Keep another supported format only when the runtime cannot load
TypeScript configuration. If an approved choice assigns Markdown to another
formatter, omit this override or remove an existing one while retaining
configuration needed by other languages.

Run `prettier --check` through Nur in the fast deterministic validation surface.
Keep costly or networked audits outside that fast loop.

# Project tasks in nurfile

Package managers own dependencies; Nur owns project tasks. The root `nurfile` is
the authoritative reference for concrete tasks, tool invocations, task
composition, and usage guidance. Read it and any relevant imported task modules
before running or changing project workflows. Generate and maintain those task
definitions according to this document and the project's actual requirements.
Discover commands through `nur --list` and focused help; keep task usage
guidance beside the definitions instead of duplicating the catalog in
`AGENTS.md`.

Keep the task catalog in a single `nurfile` while it remains manageable. Split
it only when complexity warrants multiple modules; place their implementations
under `tasks/` and import them from `nurfile`. Keep package-manager scripts only
when a framework, ecosystem, or external platform requires that interface.

Provide focused tasks for applicable responsibilities: setup, formatting,
linting, type checking, architecture, tests, licenses, vulnerabilities, builds,
generated code, databases, and deployment. Setup should be safe and preferably
idempotent. Include relevant test environments, readiness and lifecycle tasks, a
non-mutating one-shot doctor, subsystem composites, and one normal deterministic
validation entrypoint. Do not invent categories the project does not need.

Keep direct tasks thin and preserve native output and failure status. Composites
invoke focused tasks instead of repeating command lines. Run diagnostics and
tests before mutating formatters. Keep semantic, networked, costly, destructive,
and deployment workflows explicitly invoked, outside routine validation. When
deployment applies, define its focused tasks and usage guidance in `nurfile`.
Keep CI and generated-code tasks aligned with the implementation contracts.

# Panoptor

Panoptor is a persistent, language-agnostic Process Compose session for useful
validation watches, servers, workers, local services, and runtime health. Every
process invokes a Nur task; Process Compose does not own command implementation.

Adopt Panoptor only when the project has useful long-running roles that benefit
from shared status, logs, readiness, or lifecycle control. A repository with
only fast one-shot tasks does not need Panoptor; keep those tasks in Nur.

Provide a standalone `nur panoptor` command. Invoking it without a subcommand
must show the available subcommands and their usage, without starting or
changing the session.

Start headlessly by default and attach the TUI on demand. Attaching must not
start duplicate roles, detaching must leave the session running, and stopping
must terminate roles and the server. Keep headless composite workflows usable;
Panoptor is not the only validation path.

Before covered work, check for an existing session and a suitable Panoptor role.
Use its Nur controls to inspect current state, readiness, and bounded output,
and freshly rerun or restart the affected role. Do not launch duplicate
standalone watchers or services. Standalone one-shot tasks remain appropriate
when the session is absent, no role covers the check, or a prescribed
deterministic composite requires them. A role's running or previously successful
state is not evidence for the current tree; rerun it when the result may predate
relevant changes.

Define stable role names plus applicable startup dependencies, readiness probes,
restart policy, scheduled checks, and shutdown behavior. Distinguish readiness
from liveness. Do not hide crash loops with unconditional restart; select
restart behavior deliberately for each role.

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

## Watches

Use Process Compose native `watch` blocks for Panoptor roles when the selected
version supports them. Keep each Nur command one-shot so Process Compose owns
file observation, debouncing, reruns, status, logs, and lifecycle. Preserve a
non-watching Nur command for automation.

Choose narrow roots and include/exclude patterns from repository evidence.
Exclude large project-local state trees that the orchestrator's defaults do not
cover. Verify that every configured watch actually arms; schema validation alone
does not detect exhausted watcher limits or unsuitable roots. A failed one-shot
must remain visibly failed while its watch stays armed so the next edit can
recover it.

Use a tool's native development watcher only where it is intrinsic to the
framework server (for example, HMR). Avoid wrapping validation commands in
language-specific watchers underneath Process Compose because that obscures real
process state and shutdown behavior.

## Topology

Decide topology before implementation. Prefer one isolated Panoptor per worktree
only when ports, sockets, directories, databases, generated artifacts, and other
mutable resources can be isolated and machine capacity is sufficient.

Otherwise choose a main-worktree singleton. Guard its control commands.
Linked-worktree agents must not start or control it or claim its live state as
validation of their own checkout. Integrate their changes in the main worktree
before using the singleton.

# Architecture validation

Configure architecture checks against the intended graph instead of accepting
existing imports as policy. Cover all contracted framework roots and standalone
entrypoints while excluding generated and dependency trees. Verify a
representative allowed and forbidden dependency for each materially different
boundary. Expose these checks and their usage guidance through Nur. Read the
architecture configuration and module declarations identified by the project's
`Implementation details` before changing source layout or dependencies.

# Workflow validation

Validate focused tasks before composites, and exercise setup and the normal
deterministic validation entrypoint after workflow changes. Passing
configuration checks alone do not prove enforcement or successful execution.

Review diagnostics even when a validation command exits successfully. Classify
warnings and hints against the actual behavior; verify their origin before
calling them pre-existing. Fix defects introduced or exposed by the task within
its authorized scope without waiting for another request. For false positives or
inapplicable suggestions, record narrow exceptions with concrete reasons; do not
weaken checks to hide valid diagnostics.

Report unresolved issues with the affected check, evidence, and reason they
remain unresolved. Pause affected work only when proceeding requires a user
decision or exceeds the authorized scope, and continue independent work where
possible. A successful exit code alone does not establish that validation is
complete or diagnostics are clean.

## Panoptor validation

Use the pinned Process Compose version's authoritative schema and CLI help.
Validate the configuration, command discovery, `nur panoptor` usage output,
headless startup, structured list output, bounded logs, TUI attach/detach,
shutdown, and recovery. Exercise a configured one-shot watch through a real file
event and, when long-running roles exist, test their stop/start/restart
behavior. Confirm dependencies and readiness with live state, and stop the
validation session unless the user asked to leave it running.

# Version control

Use the project's selected commit style. For Conventional Commits, use
`type[optional scope]: imperative summary`. Keep commits atomic and
independently revertible, and commit only when explicitly requested. Selecting a
commit style does not authorize a commit.
