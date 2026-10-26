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
explicitly mutating; review its diff. Nushell formatting uses the pinned upstream
`nufmt` package; run it through the Nur catalog like the other formatters. Full
builds are slower and potentially networked, so run them when Nix modules,
packages, inputs, or deployment behavior change. Commands that activate NixOS
or Home Manager mutate the live machine and require an explicit deployment
request.

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
- Keep deployable raw content out of inline Nix strings. Put each script,
  application configuration, rule file, desktop entry, or other independently
  sourced artifact under `home/files` or `nixos/files`, then install it from its
  owning Nix module with `source`. Use inline `text` only for small values that
  Nix must generate or interpolate. Change a raw file and its owner together
  when their interface moves.
- User configuration and runtime state must obey the XDG Base Directory
  specification wherever the application permits it. Install files through the
  semantic Home Manager options (`xdg.configFile`, `xdg.dataFile`, and
  `xdg.stateFile`) and derive embedded paths from `config.xdg.configHome`,
  `config.xdg.dataHome`, `config.xdg.cacheHome`, `config.xdg.stateHome`, or the
  application's equivalent XDG-aware API. Modules for applications that are
  natively XDG should use those semantic locations unconditionally and do not
  need `home.preferXdgDirectories`. That preference is only for modules choosing
  between a legacy location and an XDG location; it works only when the module
  explicitly reads it and changes the managed target and any runtime discovery
  variable. Do not hardcode default paths such as `~/.config` or `~/.cache` in
  sourced files. When an application does not support XDG directly, redirect it
  with its supported environment variable or a narrow wrapper and document the
  compatibility mechanism beside the fix. A package-level XDG patch is allowed
  when no narrower supported override exists, but keep it generic and testable,
  prefer an upstreamed patch, and document migration of any existing user state.
  Protocol-defined locations such as `~/.ssh` and executable locations such as
  `~/.local/bin` and `~/.local/libexec` are intentional exceptions because XDG
  does not provide replacements for them. This repository's requirement is
  deliberately stricter than nixpkgs packaging policy; never assume a packaged
  application is XDG-compliant merely because NixOS supplies it.
- XDG does not replace general temporary storage. Use `XDG_RUNTIME_DIR` only
  for small, user-private runtime objects that belong to the current login
  session, such as sockets, locks, and named pipes; use `TMPDIR` for ordinary
  scratch files. Use XDG cache or state only when the lifetime and semantics
  genuinely match those categories.

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
NixOS configuration and standalone Home Manager output.

Use Git with Conventional Commits (`type[optional scope]: imperative summary`).
Keep commits atomic and independently revertible, and commit only when
explicitly requested.
