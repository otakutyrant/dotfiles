{ ... }:

{
  # greetd starts Sway directly, before shell startup files are read. Keep the
  # variables required by the compositor and applications it launches in the
  # system login environment rather than Home Manager's shell environment.
  environment.sessionVariables = {
    # Set Xauthority before greetd launches Sway so the compositor, XWayland
    # clients, systemd user services, and later shell setup all agree on the
    # same XDG-state file instead of falling back to ~/.Xauthority.
    XAUTHORITY = "$HOME/.local/state/X11/Xauthority";
    # CUDA defaults its JIT cache to ~/.nv/ComputeCache. Home Manager's copy of
    # this override reaches shells but not Sway, which greetd starts earlier;
    # set it here so graphical CUDA clients inherit the XDG cache location.
    CUDA_CACHE_PATH = "$HOME/.cache/nvidia/ComputeCache";
    # Retain wlroots' cursor workaround for the proprietary NVIDIA driver.
    WLR_NO_HARDWARE_CURSORS = "1";
    # Kitty uses GLFW's IBus client protocol for text-input events.
    GLFW_IM_MODULE = "ibus";
    # Prefer native Wayland rendering in Firefox and Chromium/Electron apps.
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
