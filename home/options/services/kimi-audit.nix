{ pkgs, ... }:
let
  # The command and sandbox are a reusable package. This module just installs
  # the command and schedules the selected task; no project is hard-coded.
  audit = pkgs.callPackage ../../pkgs/kimi-audit { kimi = pkgs.local.kimi-code; };
in
{
  # Keep the familiar ~/.local/bin entry updated on every Home Manager switch.
  home.file.".local/bin/kimi-audit" = {
    source = "${audit}/bin/kimi-audit";
    force = true;
  };
  # Allow future Home Manager switches to adopt independently installed units.
  xdg.configFile."systemd/user/kimi-audit.service".force = true;
  xdg.configFile."systemd/user/kimi-audit.timer".force = true;
  xdg.configFile."systemd/user/timers.target.wants/kimi-audit.timer".force = true;
  systemd.user.services.kimi-audit = {
    Unit.Description = "Continue the selected Kimi project audit when quota permits";
    Service = {
      Type = "oneshot";
      ExecStart = "${audit}/bin/kimi-audit tick --json";
      UMask = "0077";
      TimeoutStartSec = "2h";
      TimeoutStopSec = "30s";
      KillMode = "control-group";
    };
  };
  systemd.user.timers.kimi-audit = {
    Unit.Description = "Check whether the selected Kimi audit can continue";
    Timer = {
      # Saved reset times suppress requests. No task, pause and completion are
      # no-ops. Persistent catches missed calendar ticks at the next login.
      OnCalendar = "*:0/15";
      Persistent = true;
      RandomizedDelaySec = "30s";
      Unit = "kimi-audit.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
