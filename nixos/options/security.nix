{ pkgs, ... }:

{
  # Keep sudo password-protected and provide polkit for graphical elevation.
  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  # Install controller rules and grant the dedicated group access to the
  # virtual uinput device used by wdotool, not to physical input devices.
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  users.groups.uinput = { };
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
  '';
}
