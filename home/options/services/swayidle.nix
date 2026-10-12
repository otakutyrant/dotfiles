{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    events = {
      # Ironbar can remain alive with invalid Wayland surfaces after suspend,
      # which prevents its systemd restart policy from taking effect. Let the
      # compositor restore its outputs first, then recreate the panel.
      after-resume = "${pkgs.coreutils}/bin/sleep 2 && ${pkgs.systemd}/bin/systemctl --user restart ironbar.service";
    };
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
}
