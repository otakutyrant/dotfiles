{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  # Use the same patched notification daemon for package installation and XDG
  # autostart so the launched executable includes the local popup fixes.
  notificationDaemon = pkgs.local.nwg-notifications;
  # Desktop templates keep desktop-entry syntax out of Nix. The shared helper
  # fills in store paths that are only known while evaluating this profile.
  renderTemplate = import ../../lib/render-template.nix { inherit pkgs; };
in
{
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
  xdg.configFile."autostart/nwg-notifications.desktop".source =
    renderTemplate ../files/config/autostart/nwg-notifications.desktop
      {
        nwgNotifications = "${notificationDaemon}/bin/nwg-notifications";
      };
  xdg.configFile."autostart/ironbar.desktop".source =
    renderTemplate ../files/config/autostart/ironbar.desktop
      {
        ironbar = "${pkgs.ironbar}/bin/ironbar";
      };
  xdg.configFile."autostart/gnome-text-editor-scratchpad.desktop".source =
    renderTemplate ../files/config/autostart/gnome-text-editor-scratchpad.desktop
      {
        gnomeTextEditor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
        scratchpad = "${home}/Nutstore Files/Nutstore/scratchpad";
      };

  # Register rqbit as the default handler for magnet links. It submits links to
  # the persistent rqbit user service defined in the main Home Manager profile.
  xdg.dataFile."applications/rqbit.desktop".source =
    renderTemplate ../files/applications/rqbit.desktop
      {
        rqbit = "${pkgs.unstable.rqbit}/bin/rqbit";
        systemdRun = "${pkgs.systemd}/bin/systemd-run";
      };

  # Static application launchers migrated from the former Stow tree.
  xdg.dataFile."applications/kitty-ci.desktop".source = ../files/applications/kitty-ci.desktop;
  xdg.dataFile."applications/poweroff.desktop".source = ../files/applications/poweroff.desktop;
  xdg.dataFile."applications/reboot.desktop".source = ../files/applications/reboot.desktop;
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
