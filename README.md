# How to manage dotfiles

This repository is now managed primarily through a Nix flake for NixOS and
Home Manager.

## Fresh NixOS system

Clone the repository with submodules:

```nu
git clone --recursive https://github.com/otakutyrant/dotfiles.git /etc/nixos/dotfiles
cd /etc/nixos/dotfiles
```

Build the bundled host configuration:

```nu
sudo nixos-rebuild switch --flake .#nixos
passwd otakutyrant
```

The NixOS configuration creates the `otakutyrant` user, enables flakes,
NetworkManager, Docker, PipeWire, fcitx5, NVIDIA graphics, greetd, and niri.

## Home Manager only

If the system user already exists and Home Manager is installed:

```nu
home-manager switch --flake .#otakutyrant
```

Home Manager links the checked-in dotfile directories into `$HOME`. The helper
in `nixos/home.nix` recursively exposes files from directories such as `XDG`,
`niri`, `Kitty`, `Neovim`, `Nushell`, `Systemd`, and `Tmux`.

System options live in `nixos/configuration.nix`. User packages live in
`nixos/home-packages.nix`, with local package derivations under `nixos/pkgs`.

# Make dotfiles simple

Find a client which has highly refined default configuration so you do not override them too much (Neovim works well that it changes many vim default options). When overriding them, comment why you do that.

As for Neovim. If you can use third-part tool to handle files, use them rather than install an corresponding plugin, like useless Black plugin because you can execute external commands in Ex command as `:!black %`. Tinkering Neovim is ceaseless.

`nix fmt` formats Nix and Lua files through the formatter declared in
`flake.nix`. `nix run .#check` runs the same format checks plus Nix evaluation,
Lua diagnostics, and Nushell source/parser checks. Nushell is checked but not
formatted because `nufmt` has corrupted valid scripts in this repository.
`.pre-commit-config.yaml` wires these commands into pre-commit.

# Introduction to unified, hierarchical windows management

Before the introduction, let us make sure what split means. Amazingly, "split window horizontally/vertically" is terribly ambiguous in [Linux](https://english.stackexchange.com/q/293520/355018). As an ESL learner, I decide to focus in the verb "split" itself. By instinct, if I split an object, I cut it through a horizontal line. But some other people may focus in the object itself. In other words, when the object is split "horizontally", it becomes two objects, distributed in horizontal direction. No wonder some Linux software will split objects horizontally in two different ways, because they focus in either verb or noun.

To be clear. In the dotfiles, "split window horizontally" means to cut it through a horizontal line. However sometimes it is necessary to distribute windows horizontally or vertically. I won't use "split" but "distribute". I think "distribute all windows horizontally" is unambiguous. Due to some Linux software have a contract meaning of "split horizontally" from their reserved keywords in configuration, or even use "split" and "distribute" interchangeably, I will clarify them by comments, especially in niri.

Now image you have multiple windows in your screen and you are a heavy Vim user. You have a master key, used to combine with any key to manage **tabs** and **windows**. Tabs are usually numbered, and a tab contains multiple windows. Windows can be split, distributed, moved between tabs, and killed.

When you want to jump the specific tab, just hit `master+num`.

When you want split a window vertically or horizontally, hit `master+v` or `master+s` respectively. If you want distribute all windows in the current tab instantly, hit `master+|` or `master+-`, the meaning of bar and hash symbols are enough obvious.

You would like to move focus between windows via `master+hjkl`.

When you want to kill a windows, hit `master+q`.

Now time to make the windows management hierarchical! In Linux, I use niri to manage multiple GUI clients, including the Kitty terminal. Kitty manages multiple CLI clients, including shells and Neovim. Neovim then manages multiple files.

|   Hierarchies    |  name  | What do they manage? | What do master keys call in them? | binded key |
| :--------------: | :----: | -------------------- | :-------------------------------: | :--------: |
| Windows Manager  |  niri  | GUI clients          |               $mod                |   super    |
| Virtual Terminal | kitty  | CLI clients          |                N/A                |    alt     |
|      Editor      | Neovim | Files                |            learder key            |   space    |
|   Multiplixer    |  tmux  | Remote sessions      |          the prefix key           |   ctrl-w   |

| name   | What do tabs call in them? | How to allocate a new tab? | How to jump to a tab? |
| ------ | -------------------------- | -------------------------- | --------------------- |
| niri   | workspace                  | N/A                        | super+num             |
| kitty  | tab                        | alt+n                      | alt+num               |
| Neovim | tabpage                    | space+n                    | space+num             |
| tmux   | window                     | ctrl-w+n                   | ctrl-w+num            |

| name   | What do windows call in them? | How to move focus between windows? | How to split a window horizontally or vertically? | How to distribute windows horizontally or vertically? | How to kill a window? |
| ------ | ----------------------------- | ---------------------------------- | ------------------------------------------------- | ----------------------------------------------------- | --------------------- |
| niri   | window                        | super+hjkl                         | super+s or super+v                                | niri uses scrolling columns                           | super+q               |
| kitty  | window                        | alt+hjkl                           | alt+s or alt+v                                    | alt+- or alt+\|                                       | alt+q                 |
| Neovim | window                        | space+hjkl                         | space+s or space+v                                | N/A                                                   | space+q               |
| tmux   | pane                          | ctrl-w+hjkl                        | ctrl-w+s or ctrl-w+v                              | N/A                                                   | ctrl-w+q              |

Note:

1. kitty does not define master key, but you can use it anyway.
2. The niri configuration declares ten persistent named workspaces.
3. In kitty, as far as I know, when you create a window, it always is a shell.
4. In niri, `super+s` consumes the window on the right into the focused column, while `super+v` expels a window into its own column.
5. \- is a minus symbol and | bar symbol.
6. If you want to adjust the border between windows, use mouse. All hierarchies support it.
7. It seems that tmux can distribute windows too. But I have no interest to figure out how.
8. `super+t` toggles niri's tabbed display for the focused column.
9. Although I said windows can be moved between tabs, I do not list related keymaps in the table.

Do you notice the relation between master keys? They are distributed in the left-bottom part of my Happy Hacking Keyboard exactly. How well organized they are.

Haplessly, kitty cannot handle remote sessions so far. So though I dislike tmux, it is still maintained as alternative to kitty in the dotfiles and listed in the table.

![Here is the demonstration.](demo.png)

# XDG

I keep files in XDG locations when the application expects them there.

Configuration files should live under `$XDG_CONFIG_HOME` when possible. In this
repository, that usually means putting them under `XDG/.config`, which Home
Manager links into `~/.config`.

Default application choices belong in `mimeapps.list`.

Personal commands live in `$HOME/.local/bin`, although `XDG_BIN_HOME` is not
specified so far.

Desktop files are also XDG data files:

- `XDG/.local/share/applications/*.desktop` defines launcher entries for menus
  and `rofi -show drun`.
- `XDG/.config/autostart/*.desktop` defines applications started by `dex` during
  login.

Use static desktop files here when the command is stable, such as
`Exec=systemctl suspend`. If a desktop entry needs Nix interpolation, such as a
specific `${pkgs.foo}/bin/foo` path, define it with Home Manager instead.

Personal commands that should appear in rofi can be paired with a desktop file.
For example, `XDG/.local/bin/screenshot_delay.nu` is exposed through
`XDG/.local/share/applications/screenshot-delay.desktop`.

# Environment Variables

Session environment variables are managed in `nixos/home.nix`.

# Wayland and display layout

Niri owns display configuration, so ARandR and `xrandr` cannot configure this
session. First log into niri and inspect the real DRM connector names and exact
refresh rates:

```nu
niri msg outputs
```

For an ARandR-like graphical editor, launch `nwg-displays` from Rofi or a
terminal. It previews the monitor arrangement, applies it through niri, and
saves the result to `~/.config/niri/monitor.kdl`. The managed main config
already includes that writable file. `nwg-displays` is the one Python exception
in this part of the setup; the compositor, bar, wallpaper tools, notifications,
input automation, clipboard manager, screen locker, idle manager, screenshot
UI, and on-screen keyboard are Rust programs.

Try changes live before saving them. These commands are temporary and are reset
by a config reload or a later output change:

```nu
niri msg output DP-2 mode 1920x1080
niri msg output DP-2 transform 90
niri msg output DP-2 position set 0 0
niri msg output DP-4 mode 2560x1440
niri msg output DP-4 position set 1080 480
niri msg output DP-0 mode 1920x1080
niri msg output DP-0 transform 90
niri msg output DP-0 position set 3640 0
niri msg output HDMI-A-1 off
```

The names above reproduce the former X11 layout only if niri reports the same
names. NVIDIA's DRM names can differ from its XRandR names. Prefer the monitor's
`make model serial` identifier shown by `niri msg outputs` when it is available,
because it remains stable if connector numbering changes.

After the live layout works, add matching blocks to
`niri/.config/niri/config.kdl`:

```kdl
output "DP-2" {
    mode "1920x1080"
    transform "90"
    position x=0 y=0
}

output "DP-4" {
    mode "2560x1440"
    position x=1080 y=480
    focus-at-startup
}
```

Niri reloads this file when it changes. Position values use logical pixels, so
rotation and output scale affect the width and height used in the layout.

Niri's built-in screenshot UI replaces Grim and Slurp. `Print` selects a
region, `Ctrl+Print` captures the focused output, and `Alt+Print` captures the
focused window. Each action saves the image under `~/Pictures/Screenshots` and
copies it to the clipboard. The delayed screenshot launcher waits five seconds
before opening the same interactive UI.

Cthulock replaces swaylock and authenticates through its dedicated NixOS PAM
service. `Super+Shift+L` locks immediately. Stasis replaces swayidle: it starts
Cthulock after 600 idle seconds and asks niri to power off the monitors one
second later. Its D-Bus and media inhibition support prevents those actions
while an application has requested that the session remain active.

`wdotool` provides keyboard and pointer input on niri through its `/dev/uinput`
fallback. It cannot search for, focus, or close windows on this compositor; use
`niri msg windows` and `niri msg action ...` for window automation. The current
clipboard binding only needs `wdotool key`, which this backend supports.

Wired is written in Rust, but its renderer is still an X11 client. It therefore
runs through `xwayland-satellite` and may look blurry with display scaling. If
that becomes troublesome, `mako` is the mature native-Wayland notification
daemon available in Nixpkgs, although it is written in C.

# Packages

This repository targets NixOS with Home Manager. System options live in
`nixos/configuration.nix`, while user-facing development and GUI packages are
organized in `nixos/home-packages.nix`. Package names there are Nixpkgs
attribute names, not names from another distribution.

I noticed a trend that traditional GNU CLI clients are replaced by high-performance Rust alternatives, like `find` is replaced by `fd`, `grep` by `ripgrep` or `fzf`, `less` by `page` and so on.

# China network issue

There are some related configuration. Ignore them if you do not live in China.

# Too many themes and you do not know which one is the best?

Don't worry, only infants make choice, while adults want the whole enchilada! Just install all of them and random pick one every time you launch the client. You can consult how I do that in my [Neovim themes](Neovim/.config/nvim/lua/plugins/themes.lua). When fate plays its hand, a captivating theme will gracefully unfurl.

The random theme mechanism of Kitty, niri, and related applications is still a work in progress.
