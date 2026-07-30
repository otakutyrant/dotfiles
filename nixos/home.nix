{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

let
  homePackages = import ./home-packages.nix { inherit inputs pkgs; };
  home = config.home.homeDirectory;
  sessionVariables = rec {
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
    CODEX_HOME = "${XDG_CONFIG_HOME}/codex";
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
  # Recursively expose every file under a dotfile directory through Home
  # Manager, preserving each path relative to that directory.
  linkDotfileDir =
    dir:
    let
      collect =
        prefix: path:
        lib.concatMapAttrs (
          name: type:
          let
            relativePath = if prefix == "" then name else "${prefix}/${name}";
            sourcePath = path + "/${name}";
          in
          if type == "directory" then
            collect relativePath sourcePath
          else
            {
              ${relativePath}.source = sourcePath;
            }
        ) (builtins.readDir path);
    in
    collect "" dir;
  # Merge multiple dotfile directories into one Home Manager file attrset.
  linkDotfileDirs = dirs: lib.foldl' (files: dir: files // linkDotfileDir dir) { } dirs;
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";
  # These variables belong to the whole user login session, not just Nushell.
  # Home Manager writes them to the session environment so GUI apps, desktop
  # entries, terminals, and shells inherit the same baseline.
  home.sessionVariables = sessionVariables;

  # Session PATH additions. These used to be added by Nushell startup files, but
  # they are useful to programs launched outside Nushell too.
  home.sessionPath = [
    "${home}/.local/bin"
    "${home}/.nix-profile/bin"
    "${home}/.local/share/cargo/bin"
  ];

  programs.anki.enable = true;
  programs.btop.enable = true; # System monitor.
  programs.calibre.enable = true;
  programs.fd.enable = true; # Simple, fast and user-friendly alternative to find.
  programs.fzf = {
    enable = true; # Fuzzy search.
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  };
  programs.git = {
    enable = true;
    settings = {
      alias = {
        c = "commit";
        d = "diff";
        s = "status";
        g = "log --name-only --graph --all --date=format-local:'%Y-%m-%d %H:%M:%S' --format='%C(auto)%h%d %cd %s'";
        l = "log --name-only";
      };
      credential.helper = "store";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      status.showStash = true;
      user = {
        name = "otakutyrant";
        email = "otakutyrant@gmail.com";
      };
    };
  };
  programs.google-chrome.enable = true;
  programs.joshuto.enable = true; # Terminal file manager.
  programs.kitty = {
    enable = true;
    # Home Manager writes this block to kitty.conf and installs kitty, so the
    # terminal config can live beside the other program modules.
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10.0;
    };
    keybindings = {
      "alt+v" = "launch --location=vsplit --cwd=current";
      "alt+s" = "launch --location=hsplit --cwd=current";
      "alt+h" = "neighboring_window left";
      "alt+j" = "neighboring_window down";
      "alt+k" = "neighboring_window up";
      "alt+l" = "neighboring_window right";
      "alt+q" = "close_window";
      "alt+minus" = "goto_layout vertical";
      # `alt+bar` does not work here, so keep the literal bar mapping that the
      # previous kitty.conf used.
      "alt+|" = "goto_layout horizontal";
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";
      "alt+0" = "goto_tab 10";
      "alt+n" = "new_tab";
    };
    settings = {
      enabled_layouts = "splits, horizontal, vertical, grid";
      scrollback_pager = "page";
      tab_bar_style = "powerline";
      tab_title_template = "{index} : {title}";
      background_opacity = "0.8";
      allow_remote_control = "yes";
    };
  };
  # Install local mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.callPackage ./pkgs/mpv.nix { };
  };
  programs.nushell = {
    enable = true;
    environmentVariables = sessionVariables;
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
  programs.npm = {
    enable = true;
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.rofi.enable = true; # Application launcher.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        Hostname = "ssh.github.com";
        Port = 443;
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = true;
  };

  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    settings = {
      use-damage = true;
      # Let fullscreen windows bypass Picom for native refresh-rate presentation.
      unredir-if-possible = true;
      detect-client-opacity = true;
      detect-rounded-corners = true;
    };
  };
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  # Diodon ignores copied images by default. Enable image history so screenshot
  # PNG clipboard entries can appear in its menu.
  dconf.settings."net/launchpad/diodon/clipboard".add-images = true;
  xdg.userDirs.enable = true;
  xdg.configFile."user-dirs.dirs".force = true;
  # Set an explicit Xcursor theme instead of relying on toolkit fallbacks.
  # Lightweight i3 sessions do not get a desktop environment to choose one for
  # them, and GLFW/Kitty expects the active theme to provide standard resize
  # cursors such as diagonal sizing aliases.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    # font = {
    #  name = "Sarasa Gothic SC";
    # size = 13;
    # } ;
    gtk3 = {
      bookmarks = [
        "file://${home}/Pictures/Screenshots"
        "file://${home}/Nutstore%20Files/Nutstore"
        "file://${home}/Downloads"
        "file://${home}/Videos"
      ];
    };
  };
  home.packages = homePackages;

  # User services
  systemd.user.services.image-resize-daemon = {
    Unit = {
      Description = "Upscale small images under /home/otakutyrant";
      After = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${home}/.local/bin/image_resize_daemon.nu --root ${home} --target-short-side 800 --interval 5";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  # Link the checked-in dotfile directories into the user's home directory.
  home.file =
    (linkDotfileDirs [
      ../Codex
      ../mpv
      ../Neovim
      ../Tmux
      ../XDG
      ../i3
      ../joshuto
    ])
    // {
      "${home}/.local/share/Anki2/prefs21.db".force = true;
    };
}
