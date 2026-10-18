# Dotfiles project instructions

## Purpose and context

This is a personal, single-host NixOS and Home Manager configuration. Preserve
its current behavior and user-specific choices instead of generalizing it into a
reusable distribution.

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

Important commands:

- `nur format` formats checked-in Nix and Lua sources. Nushell is deliberately
  not formatted because `nufmt` has corrupted valid scripts here.
- `nur lint-nix`, `nur lint-lua`, and `nur lint-nushell` run focused linters;
  `nur lint` composes them.
- `nur typecheck-nix`, `nur typecheck-lua`, and `nur typecheck-nushell` run
  focused evaluation and diagnostics; `nur typecheck` composes them.
- `nur architecture`, `nur validate-data`, and `nur test` check repository
  boundaries, raw configuration files, and deterministic fixtures.
- `nur check` is the ordinary complete deterministic validation entrypoint.
- `nur build-nixos` and `nur build-home` realize configurations without
  activating them.
- `nur switch-nixos` and `nur switch-home` mutate the live system or profile;
  run them only when the user explicitly requests deployment.

Use focused tasks while iterating. Run `nur format`, review its diff, and then
run `nur check` after implementation. Full builds are slower and potentially
networked, so run them when Nix modules, packages, inputs, or deployment behavior
change.

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
