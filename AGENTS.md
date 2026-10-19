# Dotfiles project instructions

## Purpose and context

This is a personal, single-host NixOS and Home Manager configuration. Preserve
its current behavior and user-specific choices instead of generalizing it into a
reusable distribution.

The repository is a NixOS and Home Manager configuration built primarily with
Nix, with Lua application configuration and Nushell automation; it deliberately
has no application framework or separate language package graph.

Read `nurfile` and `tasks.nu` before changing tooling or workflows. Read the
relevant README section before changing user-visible desktop behavior. When
working below `home/`, `nixos/`, or `lib/`, inspect that tree's configuration
entrypoint and the module or helper that owns the affected file.

## Development environment and commands

The default flake development shell owns repository tools. Run commands from
the repository root after nix-direnv loads `.envrc`, or use
`nix develop --no-update-lock-file -c nur <task>`. Do not duplicate underlying
tool commands in documentation; update the Nur catalog or flake when a workflow
changes.

Discover focused formatting, linting, type, architecture, data, test, build,
deployment, and Panoptor commands through `nur --list`. Use focused tasks while
iterating and the complete deterministic check before handoff. Formatting is
explicitly mutating; review its diff. Nushell is deliberately not formatted
because `nufmt` has corrupted valid scripts here. Full builds are slower and
potentially networked, so run them when Nix modules, packages, inputs, or
deployment behavior change. Commands that activate NixOS or Home Manager mutate
the live machine and require an explicit deployment request.

Panoptor is a persistent, headless Process Compose validation session isolated
per worktree. Check for it before launching a covered validation. When it is
running, use the Nur controls to inspect role state and bounded output and to
freshly rerun affected roles; do not launch duplicate watchers. A previously
successful role is not evidence for later edits. Use standalone one-shot tasks
when Panoptor is absent, lacks a suitable role, or the deterministic composite
workflow requires them. Attaching or detaching the TUI must not start or stop
the session, and one worktree must never control or claim another's live state.

The Yihui desktop launcher is separate from this repository's Panoptor. It
starts Yihui's main-worktree singleton only when absent, then focuses or opens a
Kitty TUI client; hiding or closing that client must not duplicate or terminate
Yihui's roles.

## Architecture and ownership

- `flake.nix` is the sole integration point for NixOS, Home Manager, overlays,
  local packages, and development-shell outputs.
- `nixos/configuration.nix` owns system configuration; files under `nixos/` may
  use `lib/` but must not import `home/` directly.
- `home/configuration.nix` owns user configuration; files under `home/` may use
  `lib/` and local derivations under `home/pkgs`, but must not import `nixos/`
  directly.
- `lib/` contains shared Nix helpers and must not depend on either configuration
  tree. `nur architecture` enforces these direct dependency boundaries.
- `lib/import-modules.nix` recursively discovers module and option files in
  deterministic order. Adding a file beneath an imported `modules` or `options`
  directory does not require a central import-list edit.
- Raw files under `home/files` and `nixos/files` are installed by an owning Nix
  module. Change the raw file and its owner together when their interface moves.

Use Nixdoc comments for reusable Nix helpers, LDoc/LuaDoc annotations for
exported Lua APIs, and concise help comments for public Nushell commands. Keep
explanatory Nix comments, especially where syntax or a non-obvious NixOS choice
would otherwise be hard to understand.

## Safety and repository hygiene

Do not edit `nixos/hardware-configuration.nix` unless the task is explicitly
about detected hardware. Treat `flake.lock` as generated dependency state and
change it only through an intentional input update.

Never commit credentials, `.env` files, private API keys, or personal runtime
state. The local Zhongdou Sans flake input intentionally points to a checkout
outside this repository; do not replace or vendor it without explicit direction.

Preserve unrelated worktree changes. Keep compatibility with both the integrated
NixOS configuration and standalone Home Manager output. Use Conventional Commits
for requested commits, and split large work into independently reviewable and
revertible commits when useful; do not commit unless the user asks.
