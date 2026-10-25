{
  config,
  lib,
  pkgs,
  ...
}:

let
  preferencesFile = "${config.xdg.dataHome}/org.localsend.localsend_app/shared_preferences.json";
  # LocalSend owns mutable state in this JSON file, including its generated
  # identity. Merge the one policy-controlled preference instead of replacing
  # the complete file with a read-only Home Manager link.
  configurePreferences = ../../files/config/localsend/configure-preferences.nu;
in

{
  # Keep LocalSend available in the tray to receive files throughout the
  # graphical session. Restart only failures so an intentional quit is kept.
  systemd.user.services.localsend = {
    Unit = {
      Description = "LocalSend file transfer client";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStartPre = "${pkgs.nushell}/bin/nu ${configurePreferences} ${lib.escapeShellArg preferencesFile}";
      # Home Manager may restart the unit during a switch; keep that restart
      # in the system tray instead of opening LocalSend's main window.
      ExecStart = "${pkgs.localsend}/bin/localsend_app --hidden";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
