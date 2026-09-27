{
  config,
  inputs,
  lib,
  pkgs,
  pkgs-chatgpt,
  pkgs-unstable,
  username,
  ...
}:

let
  # Use one patched daemon for both installation and XDG autostart.
  notificationDaemon = pkgs-unstable.callPackage ./pkgs/nwg-notifications.nix { };
  homePackages = import ./home-packages.nix {
    inherit
      inputs
      notificationDaemon
      pkgs
      pkgs-chatgpt
      pkgs-unstable
      ;
  };
  home = config.home.homeDirectory;
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
  # Keep large Home Manager option groups in focused sibling modules so this
  # file stays readable while still evaluating as one merged user profile.
  imports = [
    ./options/codex.nix
    ./options/direnv.nix
    ./options/env.nix
    ./options/git.nix
    ./options/kitty.nix
    ./options/nushell.nix
    ./options/ssh.nix
    ./options/starship.nix
  ];

  # Clipcat has separate configuration files for its clipboard daemon and
  # clients. Keep their Unix socket paths in sync so the menu and CLI can talk
  # to the daemon started by Sway.
  xdg.configFile."clipcat/clipcatd.toml".text = ''
    daemonize = true
    pid_file = "/run/user/1000/clipcatd.pid"
    primary_threshold_ms = 5000
    max_history = 50
    clear_history_on_start = false
    synchronize_selection_with_clipboard = false
    history_file_path = "/home/otakutyrant/.cache/clipcat/clipcatd-history"
    snippets = []

    [log]
    emit_journald = true
    emit_stdout = false
    emit_stderr = false
    level = "INFO"

    [watcher]
    enable_clipboard = true
    enable_primary = false
    enable_secondary = false
    sensitive_mime_types = ["x-kde-passwordManagerHint"]
    filter_text_min_length = 1
    filter_text_max_length = 20000000
    denied_text_regex_patterns = []
    capture_image = true
    # Screenshots can exceed Clipcat's 5 MiB default image limit.
    filter_image_max_size = 26214400

    [grpc]
    enable_http = false
    enable_local_socket = true
    host = "127.0.0.1"
    port = 45045
    local_socket = "/run/user/1000/clipcat/grpc.sock"

    [dbus]
    enable = true

    [metrics]
    enable = false
    host = "127.0.0.1"
    port = 45047

    [desktop_notification]
    enable = true
    icon = "accessories-clipboard"
    timeout_ms = 2000
    long_plaintext_length = 2000
  '';
  xdg.configFile."clipcat/clipcatctl.toml".text = ''
    server_endpoint = "/run/user/1000/clipcat/grpc.sock"
    preview_length = 100
    grpc_max_message_size = 8388608

    [log]
    emit_journald = true
    emit_stdout = false
    emit_stderr = false
    level = "INFO"
  '';
  xdg.configFile."clipcat/clipcat-menu.toml".text = ''
    server_endpoint = "/run/user/1000/clipcat/grpc.sock"
    finder = "custom"
    preview_length = 80
    grpc_max_message_size = 8388608

    [log]
    emit_journald = true
    emit_stdout = false
    emit_stderr = false
    level = "INFO"

    [custom_finder]
    program = "walker"
    args = ["--dmenu", "--exit", "--placeholder", "Clipcat"]
  '';
  # Start programs through XDG autostart when they have no Home Manager or
  # NixOS service option. Waytrogen needs --restore, and the editor entry keeps
  # opening the configured scratchpad file on login.
  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.wechat}/share/applications/wechat.desktop"
      (pkgs.writeText "waytrogen-restore.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Waytrogen Restore
        Exec=${pkgs.waytrogen}/bin/waytrogen --restore
        Terminal=false
        NoDisplay=true
      '')
      (pkgs.writeText "nwg-notifications.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=NWG Notifications
        Exec=${notificationDaemon}/bin/nwg-notifications --wm sway
        Terminal=false
        NoDisplay=true
      '')
      (pkgs.writeText "ironbar.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Ironbar
        Exec=${pkgs.ironbar}/bin/ironbar
        Terminal=false
        NoDisplay=true
      '')
      (pkgs.writeText "gnome-text-editor-scratchpad.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=Scratchpad
        Exec=${pkgs.gnome-text-editor}/bin/gnome-text-editor "${home}/Nutstore Files/Nutstore/scratchpad"
        Terminal=false
        NoDisplay=true
      '')
    ];
  };

  # Walker has a Home Manager service option. Keep its existing launcher
  # settings and start its background application service with the session.
  services.walker = {
    enable = true;
    systemd.enable = true;
    settings = {
      force_keyboard_focus = true;
      providers.default = [ "desktopapplications" ];
      providers.empty = [ "desktopapplications" ];
    };
  };

  # Use Home Manager's service modules for these session daemons while keeping
  # the existing hand-written Clipcat configuration files above authoritative.
  services.clipcat = {
    enable = true;
    daemonSettings = { };
    ctlSettings = { };
    menuSettings = { };
  };
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 601;
        command = "${pkgs.sway}/bin/swaymsg 'output * power off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
      }
    ];
  };

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # Session PATH additions. These used to be added by Nushell startup files, but
  # they are useful to programs launched outside Nushell too.
  home.sessionPath = [
    "${home}/.local/bin"
    "${config.home.profileDirectory}/bin"
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
  programs.google-chrome.enable = true;
  programs.joshuto = {
    enable = true; # Terminal file manager.
    # Keep Joshuto's TOML settings in Home Manager; its preview scripts remain
    # linked from the joshuto directory and are referenced here by path.
    settings = {
      xdg_open = true;
      display.line_number_style = "relative";
      preview = {
        preview_script = "~/.config/joshuto/preview_file.nu";
        preview_shown_hook_script = "~/.config/joshuto/on_preview_shown.nu";
        preview_removed_hook_script = "~/.config/joshuto/on_preview_removed.nu";
      };
    };
    mimetype = {
      # Joshuto stores opener classes and MIME mappings in mimetype.toml.
      class.text_default = [ { command = "nvim"; } ];
      mimetype.text."inherit" = "text_default";
    };
  };
  # Install local mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.callPackage ./pkgs/mpv.nix { };
    # These settings replace the linked mpv.conf and input.conf files.
    config = {
      sub-visibility = "yes";
      sub-auto = "fuzzy";
      audio-file-auto = "fuzzy";
      save-position-on-quit = "yes";
      autofit-larger = "100%x100%";
      geometry = "50%:50%";
      sub-font = "Sarasa Mono Slab SC Semibold";
      sub-font-size = 40;
      sub-margin-x = 80;
      sub-margin-y = 48;
      profile = "gpu-hq";
      scale = "ewa_lanczossharp";
      cscale = "ewa_lanczossharp";
      video-sync = "display-resample";
      interpolation = true;
      tscale = "oversample";
      keep-open = "yes";
    };
    bindings = {
      RIGHT = "sub-seek 1";
      LEFT = "sub-seek -1";
      ENTER = "script-message-to subtitle_cmds ab-loop-sub pause";
      "Shift+ENTER" = "script-message-to subtitle_cmds ab-loop-sub";
      y = "script-message-to subtitle_cmds copy-subtitle";
      # Nix string interpolation must be escaped so mpv receives its own
      # ${...} expressions for the active A-B loop and current filename.
      g = ''run ffmpeg -y -nostdin -ss ''${=ab-loop-a}s -to ''${=ab-loop-b}s -fflags +genpts -i ''${stream-open-filename} -avoid_negative_ts 1 -c copy -map 0 dump_''${filename}_''${=ab-loop-a}-''${=ab-loop-b}.mp4 ; show-text "ffmpeg dumping done"'';
    };
  };
  programs.npm = {
    enable = true;
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = true;
  };

  # Ironbar reads StatusNotifier items, so start nm-applet in indicator mode
  # instead of its legacy XEmbed tray mode.
  xsession.preferStatusNotifierItems = true;
  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  xdg.userDirs.enable = true;
  xdg.configFile."user-dirs.dirs".force = true;
  # Set an explicit cursor theme because Sway is not a full desktop environment.
  # Keep the X11 link enabled so Xwayland clients use the same cursor theme.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    # Provide a desktop-wide icon theme for applications launched by Sway.
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
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
      ../mpv
      ../Neovim
      ../XDG
      ../Sway
      ../joshuto
    ])
    // {
      # Rime stores static configuration beside generated databases. Force only
      # these four paths so Home Manager can replace Rime-created regular files
      # with managed links without touching mutable user dictionaries.
      ".local/share/fcitx5/rime/default.custom.yaml" = {
        source = ../XDG/.local/share/fcitx5/rime/default.custom.yaml;
        force = true;
      };
      ".local/share/fcitx5/rime/fcitx5.custom.yaml" = {
        source = ../XDG/.local/share/fcitx5/rime/fcitx5.custom.yaml;
        force = true;
      };
      ".local/share/fcitx5/rime/terra_pinyin.custom.yaml" = {
        source = ../XDG/.local/share/fcitx5/rime/terra_pinyin.custom.yaml;
        force = true;
      };
      ".local/share/fcitx5/rime/terra_pinyin.extended.dict.yaml" = {
        source = ../XDG/.local/share/fcitx5/rime/terra_pinyin.extended.dict.yaml;
        force = true;
      };
      "${home}/.local/share/Anki2/prefs21.db".force = true;
    };

  # The dotfile directories above are linked into the Nix store, where every
  # file has the epoch mtime. Neovim's module loader (vim.loader, enabled in
  # editor.lua) caches compiled bytecode in ~/.cache/nvim/luac, keyed by path
  # and validated by mtime. When an activation re-points a config symlink to a
  # new store path, the mtime stays epoch, so the loader keeps serving stale
  # bytecode from the previous generation (e.g. oxlint silently missing after
  # switching eslint to oxlint). Clearing the cache after every activation is
  # cheap and forces recompilation from the new sources.
  home.activation.clearNvimLuacCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -rf ${home}/.cache/nvim/luac
  '';

}
