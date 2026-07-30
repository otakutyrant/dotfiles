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

    # Keep tool state under XDG locations instead of each tool's default dotdir.
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    # Enforce IPython to use XDG_CONFIG_HOME rather than ~/.ipython.
    IPYTHONDIR = "${XDG_CONFIG_HOME}/ipython";

    # A workaround to an issue #267 of ChatGPT.nvim:
    # https://github.com/jackMort/ChatGPT.nvim/issues/267#issuecomment-1676609465
    OPENAI_API_HOST = "api.openai.com";

    # User-session proxy settings. Keep loopback and Docker's Unix socket out of
    # the proxy so local dev servers and Docker CLI calls stay direct.
    http_proxy = "http://127.0.0.1:21081";
    https_proxy = http_proxy;
    HTTP_PROXY = http_proxy;
    HTTPS_PROXY = http_proxy;
    all_proxy = "socks5://127.0.0.1:21080";
    ALL_PROXY = all_proxy;
    no_proxy = builtins.concatStringsSep "," [
      "localhost"
      "127.0.0.1"
      "::1"
      "/var/run/docker.sock"
    ];
    NO_PROXY = no_proxy;

    # Input method variables used by graphical applications.
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
