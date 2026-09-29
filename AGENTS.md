# Dotfiles project instructions

## Command catalog

Read `nurfile` before making changes. It is the repository's command catalog
and defines the supported quality workflows.

Run commands through `nur` from the repository root:

- `nur format` formats checked-in Nix and Lua files.
- `nur lint` checks formatting without modifying files.
- `nur typecheck` evaluates the Nix configurations and checks Lua and
  Nushell sources.
- `nur check` runs the complete deterministic quality check.

Use the focused command while iterating, then run `nur check` after completing
the change. Do not duplicate the underlying tool commands in agent
instructions; update `nurfile` or the flake when the workflow changes.
