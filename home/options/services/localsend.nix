{ pkgs, ... }:

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
      ExecStart = "${pkgs.localsend}/bin/localsend_app";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
