{ pkgs, ... }:

{
  # The notification daemon is a background Wayland client. Supervise it so a
  # compositor/output reset during resume cannot leave notifications disabled.
  systemd.user.services.nwg-notifications = {
    Unit = {
      Description = "NWG notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.local.nwg-notifications}/bin/nwg-notifications --wm sway";
      Restart = "always";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
