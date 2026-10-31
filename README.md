# Dotfiles

My personal NixOS and Home Manager configuration: a Wayland desktop built around
Sway, GNOME applications, Rust-powered tools, and workflows that humans and
coding agents can share.

The configuration targets one `x86_64-linux` machine, host `nixos`, and user
`otakutyrant`. Nix flakes pin the system, user environment, local packages, and
development tools together. Stable Nixpkgs supplies the foundation, with
selected packages taken from unstable when the desktop or tooling needs newer
releases.

## Design priorities

- **Wayland throughout.** Sway manages windows, Ironbar provides the panel, and
  native Wayland tools handle screenshots, clipboard access, wallpapers, and
  input. XWayland remains available for applications that need it.
- **Rust-powered tools.** Prefer capable Rust applications across the shell,
  desktop, and media workflows, including Nushell, Starship, Nur, Clipcat,
  Waytrogen, rqbit, Imageflow, and OxiMedia.
- **GNOME applications.** Nautilus, File Roller, Baobab, System Monitor, Text
  Editor, and Papers provide everyday graphical tools within the Sway session.
  GTK styling, desktop portals, and file services integrate them with the
  desktop.
- **Vim-style controls across applications.** Carry familiar navigation,
  editing, and yank operations from Neovim into paging, file management, media
  playback, and batch renaming, with related focus bindings in Sway and Kitty.
- **Clear ownership.** Separate system configuration, user configuration, shared
  helpers, local packages, and raw files. Focused modules and deterministic
  discovery keep the structure navigable as it grows.
- **Declarative application configuration.** Keep complete application-native
  configuration files in the repository and install them through their owning
  Nix modules with `source`. Application settings and their deployment stay
  versioned together.
- **Strict XDG discipline.** Keep configuration, data, cache, and state in their
  XDG locations, using supported overrides where applications need help. WeChat,
  Nutstore, and Steam are the known holdouts.
- **Agent-friendly development.** Declare skills, command rules, and shared
  instructions alongside the configuration. Give agents the same task catalog
  and validation tools used interactively.
- **Continuous validation and ongoing security review.** Panoptor watches source
  changes and reruns validation roles. A separate audit inventory and ledger
  track explicitly requested security reviews against exact source identities.

## Desktop

The session starts through greetd and uses Sway's keyboard-driven workspaces,
tiling layouts, and scratchpad. The current configuration includes a
three-monitor layout and NVIDIA-specific settings; inspect
[the Sway configuration](home/files/config/sway/config) and
[NVIDIA options](nixos/options/nvidia.nix) when adapting it to other hardware.

The desktop brings together:

- Ironbar for workspaces, tray icons, and system information, including a
  Nushell helper for NVIDIA GPU statistics.
- Walker with Elephant for application launching and selection menus.
- Wayshot and Waysip for screenshots, with captures saved under
  `~/Pictures/Screenshots` and copied to the clipboard.
- Clipcat for clipboard history, wl-clipboard-rs for clipboard access, and
  wdotool for pasting a selected history item.
- Waytrogen with awww for wallpapers, nwg-notifications for notifications, and
  Swayidle with Swaylock for idle handling and locking.
- PipeWire with graphical and terminal mixers, plus fcitx5/Rime for Chinese
  input through the native Wayland frontend.

Sarasa Fixed SC supplies the text face, Zhongdou Sans contributes CJK
punctuation, and Blobmoji supplies color emoji. Adwaita icons provide a common
visual vocabulary for GTK applications.

GNOME Text Editor serves prose editing, while Neovim handles code. Neovim
delegates formatting to external tools that use project-local configuration
where available. Its
[theme configuration](home/files/config/nvim/lua/plugins/themes.lua) uses
Alabaster as the sole theme.

### Vim-style controls

Prefer tools and bindings that reuse familiar Vim habits across everyday tasks:

| Tool           | Vim-style workflow                                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Neovim         | Modal editing, motions, searches, and text operations                                                                    |
| page           | Neovim-backed paging for command output and Kitty scrollback                                                             |
| Yazi           | `h/j/k/l` navigation, `gg`/`G` for first/last entry, `Ctrl+u`/`Ctrl+d` for half-page movement, and yank/paste operations |
| mpv            | `y` yanks the current subtitle to the clipboard                                                                          |
| vimv           | Batch renaming through a Neovim-based editing workflow                                                                   |
| Sway and Kitty | Modifier plus `h/j/k/l` for directional window focus                                                                     |

[Yazi's keymap](home/options/programs/yazi.nix) also provides `dd` to cut files,
`y` to copy, and `p` to paste. The [mpv bindings](home/options/programs/mpv.nix)
extend subtitle-oriented playback with subtitle seeking, looping, and copying.
Each application keeps controls suited to its task while sharing familiar
navigation and editing habits.

### Keyboard hierarchy

Sway manages GUI clients, Kitty manages terminal windows and tabs, and Neovim
manages files and tabpages. Each layer has a distinct modifier:

| Layer  | Modifier       | Numbered destination              | Close     |
| ------ | -------------- | --------------------------------- | --------- |
| Sway   | `Super`        | `Super+1` … `Super+0`: workspaces | `Super+q` |
| Kitty  | `Alt`          | `Alt+1` … `Alt+0`: tabs           | `Alt+q`   |
| Neovim | `Space` leader | `Space+1` … `Space+0`: tabpages   | `Space+q` |

Sway and Kitty use their modifier with `h/j/k/l` to move focus. In Sway,
`Super+s` and `Super+v` select split orientation; `Super+-` and `Super+|`
arrange containers vertically and horizontally, and `Super+t` selects a tabbed
layout. Kitty uses `Alt+s` and `Alt+v` to launch horizontal and vertical splits,
with `Alt+n` for a new tab.

The authoritative bindings live in the
[Sway configuration](home/files/config/sway/config),
[Kitty module](home/options/programs/kitty.nix), and
[Neovim configuration](home/files/config/nvim).

## Repository structure

| Path                             | Responsibility                                                                        |
| -------------------------------- | ------------------------------------------------------------------------------------- |
| `flake.nix`, `flake.lock`        | Pinned inputs, overlays, local packages, configuration outputs, and development shell |
| `nixos/configuration.nix`        | System configuration entrypoint                                                       |
| `nixos/modules`, `nixos/options` | System features and focused settings                                                  |
| `nixos/files`                    | Raw files installed by system modules                                                 |
| `home/configuration.nix`         | User configuration entrypoint                                                         |
| `home/modules`                   | Groups of user packages                                                               |
| `home/options`                   | Program, service, GTK, XDG, and environment settings                                  |
| `home/pkgs`                      | Local derivations exposed through `pkgs.local`                                        |
| `home/files`                     | Application configuration, scripts, desktop entries, and agent instructions           |
| `lib`                            | Shared Nix helpers                                                                    |
| `nurfile`, `tasks.nu`, `tasks/`  | Discoverable repository commands and Panoptor controls                                |
| `process-compose.yaml`           | Panoptor validation roles and file watches                                            |
| `audits`                         | Security inventory, ledger, and retained evidence                                     |
| `docs`                           | Development and tool-selection conventions                                            |

[Module discovery](lib/import-modules.nix) recursively imports Nix files from
the configured `modules` and `options` trees in deterministic order. New modules
do not need a central import-list edit. System and user modules may use `lib`,
but must not import each other's trees; `nur architecture` checks these direct
dependency boundaries.

Raw scripts and application configuration stay in source files with an owning
Nix module that installs them. For example, the
[Neovim module](home/options/programs/neovim.nix) sources the complete Lua
configuration tree, and the [XDG module](home/options/xdg.nix) sources Sway and
Clipcat configuration. Keeping application-native files under `home/files` makes
them directly readable, editable, and lintable in their own formats. Structured
Home Manager options declare supported settings; raw files use `source`, with
templates rendered when evaluated package paths or XDG locations are needed.
Small generated values stay in Nix.

### XDG discipline

Keep the home directory tidy by following the XDG Base Directory specification
wherever applications permit it. Home Manager installs configuration, data, and
state through `xdg.configFile`, `xdg.dataFile`, and `xdg.stateFile`. Environment
variables and narrow compatibility wrappers redirect tools that need explicit
path overrides.

Examples include Cargo and Rustup under XDG data, npm and GPU compilation caches
under XDG cache, Go configuration and build caches in their respective XDG
locations, and Bash history and Xauthority under XDG state.
`home.preferXdgDirectories` selects XDG paths in Home Manager modules that
support the preference; application-specific overrides cover other tools.

The known XDG “traitors” are **WeChat, Nutstore, and Steam**: they remain
exceptions to the goal of keeping application configuration and runtime state
out of the home directory's top level. Protocol-defined paths such as `~/.ssh`
and executable locations such as `~/.local/bin` are intentional exceptions.

Personal commands live in `home/files/bin`; private helpers and templates live
in `home/files/libexec`. Session sockets and locks belong under
`XDG_RUNTIME_DIR`, while ordinary scratch files use `TMPDIR`.

User session variables belong in [home/options/env.nix](home/options/env.nix).
Values needed before greetd starts Sway belong in
[nixos/options/env.nix](nixos/options/env.nix). Default applications and desktop
entries are managed through [the XDG module](home/options/xdg.nix).

## Agents and security reviews

[The Codex module](home/options/programs/codex.nix) declares installed skills
from the pinned `tyrant-skills` input. Global instructions and workspace routing
are maintained as source files under `home/files`, while
[command policy](home/options/programs/codex-rules.nix) declares tool rules and
checks that referenced tool packages are installed. Codex and Kimi have trusted
sandbox launchers for working with untrusted repositories.

Security review is part of repository maintenance. The ordered
[audit inventory](audits/inventory.md) and its
[identity snapshot](audits/inventory.json) track declared packages, inputs,
modules, versions, revisions, and local content digests. The
[ledger](audits/ledger.md) records review scope, scanner evidence, limitations,
and outcomes. Changes invalidate coverage of the previous identity while
preserving audit history.

Audits start only on an explicit request and run through trusted sandbox
launchers. A completed review requires the recorded manual review and an
appropriate external dependency scan. Inventory entries alone do not establish
audit coverage; consult the ledger for current status. Panoptor's continuous
quality checks are separate from this security review workflow.

## Development and validation

The flake development shell owns the repository's quality tools. Use
`nix develop` to enter it, or `direnv allow` to approve the included nix-direnv
environment. From the repository root, discover tasks with:

```nu
nur --list
```

| Task                                  | Purpose                                                            |
| ------------------------------------- | ------------------------------------------------------------------ |
| `nur format`                          | Format Nix, Lua, Nushell, and Markdown                             |
| `nur lint`                            | Run formatting checks and static linters                           |
| `nur typecheck`                       | Evaluate NixOS and Home Manager; run LuaLS and Nushell diagnostics |
| `nur verify`                          | Check architecture, validate raw data, and run deterministic tests |
| `nur check`                           | Run the complete deterministic quality workflow                    |
| `nur build-nixos`, `nur build-home`   | Build without activating                                           |
| `nur switch-nixos`, `nur switch-home` | Build and activate the selected configuration                      |

Focused tasks such as `nur lint-markdown` and `nur typecheck-nix` are available
for iteration. The checks include Nixfmt, Statix, and Deadnix for Nix; StyLua,
Selene, and LuaLS for Lua; nufmt and nu-lint for Nushell; and Prettier for
Markdown. Raw-data validation covers YAML, TOML, JSON, and desktop entries.
Deterministic tests exercise architecture boundaries and sandbox shell
compatibility.

### Panoptor

Panoptor is a persistent, headless Process Compose session with a private
control socket per worktree. Its roles watch Nix, Lua, Nushell, and repository
data, rerunning the relevant checks after changes.

```nu
nur panoptor check
nur panoptor start
nur panoptor list
nur panoptor output nix_lint --tail 40
nur panoptor role rerun nix_lint
nur panoptor attach
nur panoptor stop
```

Attaching or closing the TUI leaves the session running. Inspect an existing
session and rerun affected roles rather than launching duplicate watchers. The
current graph has no dedicated Markdown role, so use `nur lint-markdown` for
README edits. Run `nur check` for the complete deterministic validation before
handoff.

## Using this configuration

This checkout includes personal hardware settings, paths, network choices, and
desktop preferences. Review them before deployment. In particular, the Zhongdou
Sans flake input expects a Git checkout at
`/home/otakutyrant/Projects/Zhongdou-Sans`; a fresh machine needs that source
available before evaluating the flake.

Clone into the trusted project workspace:

```nu
git clone https://github.com/otakutyrant/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
```

The flake exports `nixosConfigurations.nixos`, including Home Manager for
`otakutyrant`, and `homeConfigurations.otakutyrant` for standalone Home Manager.
After preparing the local input and entering the development environment, use
`nur build-nixos` or `nur build-home` to build the intended output. Deploy
intentionally with `nur switch-nixos` or `nur switch-home`.

The system configuration provides the user account, NVIDIA graphics,
NetworkManager, Docker, PipeWire, fcitx5, greetd, and Sway. Standalone Home
Manager manages the user environment; system services and hardware integration
remain the responsibility of the host configuration.
