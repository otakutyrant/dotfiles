{ ... }:

{
  # greetd starts Sway directly, before shell startup files are read. Keep the
  # variables required by the compositor and applications it launches in the
  # system login environment rather than Home Manager's shell environment.
  environment.sessionVariables = {
    # Retain wlroots' cursor workaround for the proprietary NVIDIA driver.
    WLR_NO_HARDWARE_CURSORS = "1";
    # Kitty uses GLFW's IBus client protocol for text-input events.
    GLFW_IM_MODULE = "ibus";
    # Prefer native Wayland rendering in Firefox and Chromium/Electron apps.
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
