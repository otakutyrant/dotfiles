{ config, pkgs, ... }:

let
  home = config.home.homeDirectory;
in
{
  # These variables belong beyond Nushell, but Home Manager's session variables
  # reach only consumers of its generated environment. A compositor started by
  # greetd before that environment is loaded, and GUI applications it launches,
  # need any required values mirrored in the NixOS login environment.
  home.sessionVariables = rec {
    # XDG base directories. Tool-specific variables below reuse these paths so
    # applications store config, cache, data, and state in predictable places.
    XDG_CONFIG_HOME = "${home}/.config";
    XDG_CACHE_HOME = "${home}/.cache";
    XDG_DATA_HOME = "${home}/.local/share";
    XDG_STATE_HOME = "${home}/.local/state";

    # Default command-line tools used by many programs, not just by Nushell.
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "page";
    SHELL = "${pkgs.nushell}/bin/nu";

    # Let ncurses and Codex find the Kitty database through the standard
    # search path; an empty TERMINFO avoids a stale override taking precedence.
    TERMINFO = "";
    TERMINFO_DIRS = "${pkgs.kitty}/lib/kitty/terminfo";

    # Sandboxed GUI packages such as WeChat cannot discover Nix-store cursor
    # themes through their FHS filesystem.  Expose Bibata's icon directory so
    # they use the configured 24px cursor instead of a large fallback cursor.
    XCURSOR_PATH = "${pkgs.bibata-cursors}/share/icons";

    # Keep tool state and caches under XDG locations instead of each tool's
    # default top-level dotdir.
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nvidia/ComputeCache";
    TRITON_CACHE_DIR = "${XDG_CACHE_HOME}/triton";
    XCOMPOSECACHE = "${XDG_CACHE_HOME}/X11/compose";

    # Go's default GOPATH is ~/go. Keep installed tools and persistent Go state
    # under XDG data while treating downloaded modules and build objects as
    # caches with independent lifetimes.
    GOPATH = "${XDG_DATA_HOME}/go";
    GOBIN = "${GOPATH}/bin";
    GOMODCACHE = "${XDG_CACHE_HOME}/go/mod";
    GOCACHE = "${XDG_CACHE_HOME}/go/build";
    GOENV = "${XDG_CONFIG_HOME}/go/env";

    # NixOS sets the same value through PAM before greetd starts Sway. Repeat it
    # here so standalone Home Manager and generated shell environments agree.
    XAUTHORITY = "${XDG_STATE_HOME}/X11/Xauthority";

    # Bash is installed for Home Manager and is occasionally invoked manually.
    # Keep that fallback shell from recreating ~/.bash_history.
    HISTFILE = "${XDG_STATE_HOME}/bash/history";

    # Fcitx5's native Wayland frontend is enabled in configuration.nix. Do
    # not force GTK or Qt to use the legacy X11/DBus frontend here: on native
    # Wayland apps that bypasses the compositor-provided cursor rectangle and
    # can put the candidate panel at an incorrect screen edge.  X11 apps use
    # XMODIFIERS through XWayland instead.
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  # Bash cannot create HISTFILE's parent itself. Managing a sentinel keeps the
  # state directory available without treating mutable history as Nix data.
  xdg.stateFile."bash/.keep".text = "";
  # XAUTHORITY is selected before the graphical session starts, so its parent
  # must already exist rather than relying on an X11 client to create it.
  xdg.stateFile."X11/.keep".text = "";
}
