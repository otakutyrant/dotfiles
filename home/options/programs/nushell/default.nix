{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Home Manager can add shell-expansion fragments to XDG_DATA_DIRS, such as
  # `${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}`. Those fragments are valid in POSIX
  # session setup scripts, but Nushell would store them literally and break
  # programs like Neovim that split XDG_DATA_DIRS.
  nushellEnvironmentVariables = lib.removeAttrs config.home.sessionVariables [ "XDG_DATA_DIRS" ];
  # This template keeps the Nushell environment logic in Nushell while still
  # receiving Home Manager's evaluated session path as a Nushell list literal.
  nushellExtraEnv = pkgs.replaceVars ./extra-env.nu {
    sessionPath = builtins.toJSON config.home.sessionPath;
  };
in

{
  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    # Do not pass XDG_DATA_DIRS through this option. Home Manager's value may
    # contain POSIX shell syntax that Nushell would keep literally, which makes
    # Neovim build a broken runtimepath and print E79 wildcard errors.
    environmentVariables = nushellEnvironmentVariables;
    # Source focused Nushell files so this module only wires configuration
    # together instead of embedding substantial shell programs. `source-env`
    # carries environment changes back into Nushell's generated env file.
    extraEnv = "source-env ${nushellExtraEnv}";
    settings = {
      show_banner = false;
      buffer_editor = "nvim";
    };
    extraConfig = "source ${./extra-config.nu}";
    shellAliases = {
      # Show directory contents fully, alias `ls -al`.
      ll = "ls -al";

      # Kitty window control.
      wider = "kitty @ resize-window --self --axis=horizontal --increment=60";

      # Neovim shortcuts.
      vi = "nvim";
      cvi = ''nvim -p -c "tabdo lcd %:p:h"'';

      # ripgrep: Pretty output so it can pipe into pagers.
      rg = "rg -p";

      # Enables ssh trusted X11 forwarding. So you can access the X of remote hosts.
      ssh = "ssh -Y";

      # systemd shortcut.
      sc = "systemctl";

      # yt-dlp: Solve China network issue via proxy, and download Chinese
      # subtitles automatically.
      "yt-dlp" = "yt-dlp --proxy 127.0.0.1:2340 --write-subs --sub-langs zh-CN";

    };
    # `with pkgs.nushellPlugins;` lets the list use plugin package names
    # directly. These packages are registered by Home Manager so Nushell can
    # load their commands.
    plugins = with pkgs.nushellPlugins; [
      desktop_notifications # Send desktop notifications from Nushell scripts.
      formats # Add extra converters for structured file formats.
      hcl # Parse HashiCorp Configuration Language files such as Terraform configs.
      polars # Add dataframe commands backed by the Polars data engine.
      query # Query structured data such as JSON, XML, HTML, and web responses.
      semver # Parse and compare semantic version strings.
      skim # Integrate the skim fuzzy finder with Nushell pipelines.
      # dbus, net, and units are omitted because this nixpkgs revision marks
      # their Nushell plugin packages as broken.
    ];
  };
}
