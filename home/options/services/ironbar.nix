{ pkgs, ... }:

{
  # Ironbar is the only consumer of this probe, so keep its implementation out
  # of the user's command search path and invoke it explicitly through Nushell.
  home.file.".local/libexec/gpu_status.nu".source = ../../files/libexec/gpu_status.nu;

  # Run Ironbar under the user manager instead of as a one-shot XDG autostart
  # process. A Wayland client can exit when its output disappears during
  # suspend; Restart=always brings the panel back once the session resumes.
  systemd.user.services.ironbar = {
    Unit = {
      Description = "Ironbar Wayland panel";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.ironbar}/bin/ironbar";
      Restart = "always";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
