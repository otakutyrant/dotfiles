{ config, pkgs-unstable, ... }:

{
  # Configure the NVIDIA driver at the NixOS module level. This belongs under
  # `options/` rather than `pkgs/` because it sets NixOS options instead of
  # defining a new package derivation.
  hardware.nvidia = {
    # Enable the DRM kernel modesetting path required by modern compositors,
    # PRIME/offload setups, and smoother early display handoff.
    modesetting.enable = true;
    # Use NVIDIA's open kernel modules. User-space libraries are still
    # proprietary, but the kernel module portion uses the open variant.
    open = true;
    # Install the `nvidia-settings` control panel for inspecting and adjusting
    # NVIDIA driver options from the desktop.
    nvidiaSettings = true;
    # Enable driver-level power management so suspend/resume and GPU power states
    # are handled by NVIDIA's power management support.
    powerManagement.enable = true;
    # Read the newer driver version and verified source hashes from unstable to
    # avoid the 595.71.05 shader-compiler crash on the RTX 5060. The stable
    # kernel package set still performs the build, which keeps the module tied
    # to this system's kernel and avoids importing unrelated unstable libraries.
    package =
      let
        unstableNvidia = pkgs-unstable.linuxPackages.nvidiaPackages.latest;
      in
      config.boot.kernelPackages.nvidiaPackages.mkDriver {
        inherit (unstableNvidia) version;
        sha256_64bit = unstableNvidia.src.outputHash;
        openSha256 = unstableNvidia.open.src.outputHash;
        settingsSha256 = unstableNvidia.settings.src.outputHash;
        persistencedSha256 = unstableNvidia.persistenced.src.outputHash;
      };
  };
}
