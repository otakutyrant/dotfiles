This is a Tyrant convention.

# Tool selection

This document defines Tyrant conventions for project-wide tools, language
tools, documentation styles, and architecture-checker ownership.

## Project-wide tools

| Responsibility | Tyrant convention | Boundary |
| --- | --- | --- |
| General shell | Nushell | Portable commands and project automation. |
| Development environment | `nix develop` through a Nix flake | Reproducible package-level environment with root `.envrc`. |
| Task runner | Nur with a root `nurfile` | Human and agent command surface. |
| Dependency security | OSV-Scanner | Scan committed supported lockfiles; keep exceptions explicit. |
| Panoptor | Headless Process Compose with attachable TUI | Concurrent roles, status, logs, readiness, and lifecycle control. |
| Panoptor topology | One isolated Panoptor per active worktree | Use only when ports, state, and resources can be isolated. |
| Version control | Git | Own repository history and worktree operations. |
| Commit style | Conventional Commits | Use the compact policy below. |

When Nix is selected, keep project executables in the development shell and
enter it through a tracked `.envrc` containing `use flake`. Keep additional
required directives. `direnv allow` is a per-user trust decision, not a task.

Package-manager scripts must not duplicate Nur tasks. Retain them only when a
framework, ecosystem, or external platform requires that interface. Make the
Nur catalog self-describing and keep `AGENTS.md` pointed at its listing/help
surface rather than copying command names.

Use this compact, self-contained guidance:

> Use Git with Conventional Commits (`type[optional scope]: imperative
> summary`). Keep commits atomic and independently revertible, and commit only
> when explicitly requested.

Treat its three clauses as separate decisions: message style, commit
granularity, and authorization. Never let a selected style imply permission to
commit.

## Language tools

Decide only applicable responsibilities; interactors are optional.

| Responsibility | TypeScript | Python | Lua | Nushell |
| --- | --- | --- | --- | --- |
| Package manager | pnpm | uv | LuaRocks | Nupm when needed |
| Database | Prisma | not applicable | not applicable | not applicable |
| Linter | Oxlint with `oxlint-plugin-eslint` and `oxlint-tsgolint` | Ruff and Pylint | Selene | Tyrant `nu-lint` fork |
| Formatter | Prettier | Ruff | StyLua | `nufmt` |
| Tester | Vitest | pytest | busted | `std/assert`; `nupm test` with Nupm |
| Logger | Winston | `logging` | LuaLogging | `std/log` |
| Interactor | tsx | IPython | runtime REPL | Nushell |
| Declutter | Knip | Ruff first; Deptry for dependency drift | Selene; no dependency-drift default | `nu-lint` |
| Progress | cli-progress | tqdm | none | none |
| Data validation | Zod | Pydantic | tableshape | signatures and typed records |
| Type checking | `tsc` | basedpyright | LuaLS | Nushell typing plus `nu-lint` |
| Rate limiting | Bottleneck | `asyncio` unless quotas need more | framework/runtime choice | `par-each --threads`; no limiter |
| ANSI styling | picocolors | no package unless needed | escapes; ansicolors when useful | built-in `ansi` |
| Profiling | Node/V8 profiler | `cProfile` | LuaJIT profiler when applicable | `timeit` for timing only |
| License checking | `pnpm licenses` | pip-licenses | none | none |
| Architecture | dependency-cruiser | existing rules; Import Linter for real layers | none | none |

LuaRocks owns libraries and tools distributed as rocks. Put standalone tools
such as Selene and StyLua in the approved Nix environment when LuaRocks does
not distribute them; do not choose a weaker tool merely to share an installer.

Framework-specific tools may supplement, rather than replace, a primary tool
when they own a distinct boundary. Prefer runtime or standard-library
capabilities over another dependency. Keep costly or networked audits outside
the fast deterministic loop.

## Documentation styles

Decide independently per applicable language.

| TypeScript | Python | Lua | Nushell | Nix |
| --- | --- | --- | --- | --- |
| TSDoc | reStructuredText | LDoc | custom commands | Nixdoc |

## Architecture checks

Encode the intended graph instead of accepting existing imports as policy.
Cover all contracted framework roots and standalone entrypoints while excluding
generated/dependency trees. Verify one representative allowed and forbidden
dependency for each materially different boundary.

## Project deviations

None.
