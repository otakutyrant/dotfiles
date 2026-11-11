{
  config,
  lib,
  pkgs,
  ...
}:

let
  desktopDefaults = import ../../lib/session-environment.nix {
    cacheHome = config.xdg.cacheHome;
    stateHome = config.xdg.stateHome;
  };
  # Only these public values belong in desktop and service environments. Shell
  # startup may load credentials, proxies and tool hooks that must stay local.
  desktopNames = builtins.attrNames desktopDefaults ++ [
    "XDG_CONFIG_HOME"
    "XDG_CACHE_HOME"
    "XDG_DATA_HOME"
    "XDG_STATE_HOME"
    "XCURSOR_PATH"
    "XCURSOR_THEME"
    "XCURSOR_SIZE"
    "EDITOR"
    "VISUAL"
    "PAGER"
    "CARGO_HOME"
    "RUSTUP_HOME"
    "GOPATH"
    "GOBIN"
    "GOMODCACHE"
    "GOCACHE"
    "GOENV"
    "TRITON_CACHE_DIR"
    "CODEX_HOME"
    "KIMI_CODE_HOME"
    "NPM_CONFIG_USERCONFIG"
  ];
  desktopEnvironment = lib.getAttrs desktopNames config.home.sessionVariables;
  sessionPath = lib.concatStringsSep ":" config.home.sessionPath;
  environmentFile = "${config.xdg.configHome}/session/environment.sh";
  renderTemplate = import ../../lib/render-template.nix { inherit pkgs; };
in
{
  # Keep standalone Home Manager usable without the NixOS PAM module. The same
  # values feed the login profile, user manager and Nushell; no shell has to
  # run first to repair the graphical environment.
  home.sessionVariables = desktopDefaults // rec {
    # XDG base directories. Tool-specific variables below reuse these paths so
    # applications store config, cache, data, and state in predictable places.
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_STATE_HOME = config.xdg.stateHome;

    # Default command-line tools used by many programs, not just by Nushell.
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "page";
    # SHELL comes from the account configuration in nixos/options/users.nix.

    # Let ncurses and Codex find the Kitty database through the standard
    # search path; an empty TERMINFO avoids a stale override taking precedence.
    TERMINFO = "";
    TERMINFO_DIRS = "${pkgs.kitty}/lib/kitty/terminfo";

    # Sandboxed GUI packages such as WeChat cannot discover Nix-store cursor
    # themes through their FHS filesystem.  Expose Bibata's icon directory so
    # they use the configured 24px cursor instead of a large fallback cursor.
    XCURSOR_PATH = "${config.home.pointerCursor.package}/share/icons";

    # Keep tool state and caches under XDG locations instead of each tool's
    # default top-level dotdir.
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    TRITON_CACHE_DIR = "${XDG_CACHE_HOME}/triton";

    # Go's default GOPATH is ~/go. Keep installed tools and persistent Go state
    # under XDG data while treating downloaded modules and build objects as
    # caches with independent lifetimes.
    GOPATH = "${XDG_DATA_HOME}/go";
    GOBIN = "${GOPATH}/bin";
    GOMODCACHE = "${XDG_CACHE_HOME}/go/mod";
    GOCACHE = "${XDG_CACHE_HOME}/go/build";
    GOENV = "${XDG_CONFIG_HOME}/go/env";

    # Bash is installed for Home Manager and is occasionally invoked manually.
    # Keep that fallback shell from recreating ~/.bash_history.
    HISTFILE = "${XDG_STATE_HOME}/bash/history";
  };

  # The user manager is not a child of Sway. Its static environment must be
  # available before graphical-session.target starts any launcher services.
  systemd.user.sessionVariables = desktopEnvironment;
  # NixOS's 50-systemd-path.conf replaces PATH after Home Manager's default
  # 10-home-manager.conf. Append personal precedence only after that baseline.
  xdg.configFile."environment.d/90-desktop-path.conf".text = ''
    PATH=${sessionPath}:''${PATH}
  '';

  # Generate only assignments from Nix data. Preserve inherited system paths;
  # source once per process tree so nested login shells do not grow PATH.
  xdg.configFile."session/environment.sh".text = ''
    if [ -z "''${DOTFILES_DESKTOP_ENV_LOADED-}" ]; then
      export DOTFILES_DESKTOP_ENV_LOADED=1
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: value: "export ${name}=${lib.escapeShellArg (toString value)}"
        ) desktopEnvironment
      )}
      export PATH=${lib.escapeShellArg sessionPath}"''${PATH:+:}$PATH"
    fi
  '';
  # .profile is greetd's fixed protocol entry; the environment itself remains
  # XDG-managed. Home Manager refuses to overwrite an existing unmanaged file.
  home.file.".profile".source = renderTemplate ../files/session/profile {
    inherit environmentFile;
  };
  home.file.".local/libexec/start-desktop-session" = {
    executable = true;
    source = renderTemplate ../files/libexec/start-desktop-session.sh {
      inherit environmentFile;
      environmentNames = lib.escapeShellArgs desktopNames;
      dbusUpdate = "${pkgs.dbus}/bin/dbus-update-activation-environment";
      systemctl = "${pkgs.systemd}/bin/systemctl";
    };
  };

  # Bash cannot create HISTFILE's parent itself. Managing a sentinel keeps the
  # state directory available without treating mutable history as Nix data.
  xdg.stateFile."bash/.keep".text = "";
  # XAUTHORITY is selected before the graphical session starts, so its parent
  # must already exist rather than relying on an X11 client to create it.
  xdg.stateFile."X11/.keep".text = "";
}
