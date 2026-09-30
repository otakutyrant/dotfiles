{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  # Windows shares the ESP with NixOS, so systemd-boot detects it without
  # allowing NixOS to rewrite firmware boot variables.
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    # wdotool uses a virtual kernel input device for Wayland key injection.
    "uinput"
  ];
}
