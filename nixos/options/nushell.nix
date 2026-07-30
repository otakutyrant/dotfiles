{ config, pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    environmentVariables = config.home.sessionVariables;
    extraEnv = ''
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
          $env.http_proxy = "http://127.0.0.1:21081"
          $env.https_proxy = "http://127.0.0.1:21081"
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
