{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  # Desktop templates keep desktop-entry syntax out of Nix. The shared helper
  # fills in store paths that are only known while evaluating this profile.
  renderTemplate = import ../../lib/render-template.nix { inherit pkgs; };
  # rqbit 9 no longer has a CLI option for submitting downloads to a running
  # server, so bridge desktop magnet links to its HTTP API. Keep the Nushell
  # implementation in files/bin and substitute only immutable package paths.
  rqbitMagnetHandler = renderTemplate ../files/bin/rqbit_magnet_handler.nu {
    curl = "${pkgs.curl}/bin/curl";
    notifySend = "${pkgs.libnotify}/bin/notify-send";
    nu = "${pkgs.nushell}/bin/nu";
    systemctl = "${pkgs.systemd}/bin/systemctl";
  };
  # Use the same rendered entry in the application menu and XDG autostart so
  # both launch the qBittorrent package selected by this Home Manager profile.
  qbittorrentDesktopEntry = renderTemplate ../files/applications/qbittorrent.desktop {
    qbittorrent = "${pkgs.qbittorrent}/bin/qbittorrent";
  };
in
{
  home.file.".local/bin/rqbit-magnet-handler" = {
    source = rqbitMagnetHandler;
    executable = true;
  };

  # Clipcat has separate configuration files for its clipboard daemon and
  # clients. Keep their Unix socket paths in sync so the menu and CLI can talk
  # to the daemon started by Sway.
  xdg.configFile."clipcat/clipcatd.toml".source = ../files/config/clipcat/clipcatd.toml;
  xdg.configFile."clipcat/clipcatctl.toml".source = ../files/config/clipcat/clipcatctl.toml;
  xdg.configFile."clipcat/clipcat-menu.toml".source = ../files/config/clipcat/clipcat-menu.toml;

  # Source desktop-environment files that do not have a more focused Home
  # Manager option while retaining their standard XDG locations.
  xdg.configFile."mimeapps.list".source = ../files/config/mimeapps.list;
  xdg.configFile."sway" = {
    source = ../files/config/sway;
    recursive = true;
  };
  xdg.configFile."ironbar" = {
    source = ../files/config/ironbar;
    recursive = true;
  };
  xdg.configFile."wired" = {
    source = ../files/config/wired;
    recursive = true;
  };

  # Fcitx gives ~/.config precedence over the system-wide configuration from
  # NixOS. Manage the Classic UI preferences here so a stale configtool file
  # cannot restore the wide horizontal candidate row across monitor edges.
  xdg.configFile."fcitx5/conf/classicui.conf" = {
    force = true;
    text = ''
      Vertical Candidate List=True
      WheelForPaging=True
      Font="Sarasa Fixed SC 22"
    '';
  };

  # Start programs through XDG autostart when they have no Home Manager or
  # NixOS service option. Waytrogen needs --restore, and the editor entry keeps
  # opening the configured scratchpad file on login.
  xdg.autostart = {
    enable = true;
    entries = [ "${pkgs.wechat}/share/applications/wechat.desktop" ];
  };
  xdg.configFile."autostart/waytrogen-restore.desktop".source =
    renderTemplate ../files/config/autostart/waytrogen-restore.desktop
      {
        waytrogen = "${pkgs.waytrogen}/bin/waytrogen";
      };
  xdg.configFile."autostart/gnome-text-editor-scratchpad.desktop".source =
    renderTemplate ../files/config/autostart/gnome-text-editor-scratchpad.desktop
      {
        gnomeTextEditor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
        scratchpad = "${home}/Nutstore Files/Nutstore/scratchpad";
      };
  xdg.configFile."autostart/qbittorrent.desktop".source = qbittorrentDesktopEntry;

  # Register rqbit as the default handler for magnet links. It submits links to
  # the persistent rqbit user service defined in the main Home Manager profile.
  xdg.dataFile."applications/rqbit.desktop".source =
    renderTemplate ../files/applications/rqbit.desktop
      {
        rqbitMagnetHandler = "${home}/.local/bin/rqbit-magnet-handler";
        systemdRun = "${pkgs.systemd}/bin/systemd-run";
      };
  xdg.dataFile."applications/qbittorrent.desktop".source = qbittorrentDesktopEntry;

  # The launcher focuses or creates a Kitty TUI client while keeping Yihui's
  # headless Process Compose session as the independent lifecycle owner.
  xdg.dataFile."applications/yihui-panoptor.desktop".source =
    ../files/applications/yihui-panoptor.desktop;
  xdg.dataFile."applications/poweroff.desktop".source = ../files/applications/poweroff.desktop;
  xdg.dataFile."applications/reboot.desktop".source = ../files/applications/reboot.desktop;
  xdg.dataFile."applications/screenshot-all-monitors.desktop".source =
    ../files/applications/screenshot-all-monitors.desktop;
  xdg.dataFile."applications/screenshot-delay.desktop".source =
    ../files/applications/screenshot-delay.desktop;
  xdg.dataFile."applications/sleep.desktop".source = ../files/applications/sleep.desktop;

  # Desktop files under ~/.local/share are linked after Home Manager builds its
  # package profile, so refresh the per-user cache once those links are in
  # place. GTK's application chooser otherwise keeps an older mimeinfo.cache
  # and can report that no application supports a newly added URI scheme.
  home.activation.updateUserDesktopDatabase = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.desktop-file-utils}/bin/update-desktop-database ${lib.escapeShellArg "${config.xdg.dataHome}/applications"}
  '';

  # Rime stores static configuration beside generated databases. Force only
  # these paths so activation does not replace mutable user dictionaries.
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    source = ../files/rime/default.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/fcitx5.custom.yaml" = {
    source = ../files/rime/fcitx5.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/terra_pinyin.custom.yaml" = {
    source = ../files/rime/terra_pinyin.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/terra_pinyin.extended.dict.yaml" = {
    source = ../files/rime/terra_pinyin.extended.dict.yaml;
    force = true;
  };

  xdg.userDirs.enable = true;
  # xdg-user-dirs may create this file before Home Manager manages it.
  xdg.configFile."user-dirs.dirs".force = true;
}
