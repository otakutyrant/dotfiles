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
  homePackages = import ./home-packages.nix {
    inherit
      inputs
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
    # These package modules install the Wayland utilities and keep their
    # generated configuration beside the corresponding package declaration.
    ./pkgs/cthulock.nix
    ./pkgs/stasis.nix
  ];

  # Clipcat has separate configuration files for its clipboard daemon and
  # clients. Keep their Unix socket paths in sync so the menu and CLI can talk
  # to the daemon started by niri.
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
    finder = "rofi"
    preview_length = 80
    grpc_max_message_size = 8388608

    [log]
    emit_journald = true
    emit_stdout = false
    emit_stderr = false
    level = "INFO"

    [rofi]
    line_length = 100
    menu_length = 30
    menu_prompt = "Clipcat"
    extra_arguments = []
    show_source_prefix = false
  '';

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

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
  programs.google-chrome.enable = true;
  programs.joshuto.enable = true; # Terminal file manager.
  # Install local mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.callPackage ./pkgs/mpv.nix { };
  };
  programs.npm = {
    enable = true;
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.rofi.enable = true; # Application launcher.
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = true;
  };

  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  xdg.userDirs.enable = true;
  xdg.configFile."user-dirs.dirs".force = true;
  # Set an explicit cursor theme because niri is not a full desktop environment.
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
    # Provide a desktop-wide icon theme for applications launched by niri.
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
      ../Tmux
      ../XDG
      ../niri
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

  # nwg-displays needs to rewrite this file, so keep it outside Home Manager's
  # immutable store links. The main niri config includes it and this creates an
  # empty initial file before nwg-displays has saved the first display layout.
  home.activation.ensureNiriMonitorConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${home}/.config/niri
    if [ ! -e ${home}/.config/niri/monitor.kdl ]; then
      touch ${home}/.config/niri/monitor.kdl
    fi
  '';
}
