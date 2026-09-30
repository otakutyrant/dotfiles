{ ... }:

{
  hardware.graphics = {
    enable = true;
    # Steam and other 32-bit games still need the compatibility drivers.
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Keep NVIDIA's static application profile as JSON so its native syntax can
  # be validated and edited independently from this Nix module.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".source =
    ../files/nvidia/50-limit-free-buffer-pool-in-wayland-compositors.json;
}
