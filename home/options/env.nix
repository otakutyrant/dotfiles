{ config, pkgs, ... }:

let
  home = config.home.homeDirectory;
in
{
  # These variables belong to the whole user login session, not just Nushell.
  # Home Manager writes them to the session environment so GUI apps, desktop
  # entries, terminals, and shells inherit the same baseline.
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

    # Keep tool state under XDG locations instead of each tool's default dotdir.
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    # Enforce IPython to use XDG_CONFIG_HOME rather than ~/.ipython.
    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";

    # A workaround to an issue #267 of ChatGPT.nvim:
    # https://github.com/jackMort/ChatGPT.nvim/issues/267#issuecomment-1676609465
    OPENAI_API_HOST = "api.openai.com";

    # Fcitx5's native Wayland frontend is enabled in configuration.nix. Do
    # not force GTK or Qt to use the legacy X11/DBus frontend here: on native
    # Wayland apps that bypasses the compositor-provided cursor rectangle and
    # can put the candidate panel at an incorrect screen edge.  X11 apps use
    # XMODIFIERS through XWayland instead.
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };
}
