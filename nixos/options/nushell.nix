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
  # Reuse Home Manager's session path list for Nushell's own environment file.
  # `config.home.sessionPath` is a Nix list of strings, but below we need to
  # splice those paths into a Nushell list literal inside `extraEnv`.
  #
  # `lib.concatMapStringsSep "\n" f list` means:
  #   1. run `f` on every item in `list`;
  #   2. join the generated strings with newline characters.
  #
  # The mapping function turns each path into one indented Nushell string item,
  # for example:
  #           "/home/otakutyrant/.local/bin"
  #
  # Keeping the indentation in the generated string makes the final Nushell
  # code readable after Nix substitutes `${nushellSessionPath}` into `extraEnv`.
  # `extraEnv` then prepends these paths to Nushell's inherited PATH instead of
  # replacing the system paths supplied by the login session.
  nushellSessionPath = lib.concatMapStringsSep "\n" (path: ''          "${path}"'') config.home.sessionPath;
in

{
  programs.nushell = {
    enable = true;
    # Do not pass XDG_DATA_DIRS through this option. Home Manager's value may
    # contain POSIX shell syntax that Nushell would keep literally, which makes
    # Neovim build a broken runtimepath and print E79 wildcard errors.
    environmentVariables = nushellEnvironmentVariables;
    extraEnv = ''
      # Home Manager's `home.sessionPath` is written for login-session setup,
      # but Nushell starts from its own generated environment. Keep these user
      # paths in Nushell too so wrappers in ~/.local/bin can override Nix
      # profile binaries.
      $env.PATH = ([
${nushellSessionPath}
      ] | append $env.PATH | uniq)

      # Prisma's downloaded schema engine is not reliable on NixOS.
      let schema_engine = (which schema-engine | get path)
      if (($schema_engine | length) > 0) {
          $env.PRISMA_SCHEMA_ENGINE_BINARY = ($schema_engine | first)
      }

      # Export local private API keys when the file exists.
      const api_keys = if ("~/api_keys.nu" | path expand | path exists) { "~/api_keys.nu" } else { null }
      source-env $api_keys
    '';
    settings = {
      show_banner = false;
      buffer_editor = "nvim";
    };
    extraConfig = ''
      # Nushell is case-insensitive in environment variables, and if I set http_proxy and
      # https_proxy, Nushell will discard HTTP_PROXY and HTTPS_PROXY.
      def --env envproxy [] {
          $env.http_proxy = "http://127.0.0.1:7890"
          $env.https_proxy = "http://127.0.0.1:7890"
          "http proxy on"
      }
      def --env noproxy [] {
          hide-env HTTP_PROXY
          hide-env HTTPS_PROXY
          "http proxy off"
      }
      # WSL needs to access the host proxy through the DNS server generated in /etc/resolv.conf.
      def wsl-host-ip [] {
          # Match only real nameserver records. `find "nameserver"` can also match
          # comments, and returns `nothing` when there is no match.
          open /etc/resolv.conf | lines | where {|line| $line =~ '^\s*nameserver\s+' } | first | default "" | split row --regex '\s+' | get --optional 1 | default "" | str trim
      }
      def --env wslproxy [] {
          let wsl_host_ip = (wsl-host-ip)
          if ($wsl_host_ip | is-empty) {
              error make {msg: "could not find a nameserver in /etc/resolv.conf for WSL proxy"}
          }
          $env.http_proxy = $"http://($wsl_host_ip):21081"
          $env.https_proxy = $"http://($wsl_host_ip):21081"
          "http proxy on"
      }
    '';
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
