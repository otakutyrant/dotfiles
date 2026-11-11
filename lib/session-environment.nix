/**
  Static desktop defaults shared by PAM and standalone Home Manager.

  PAM callers pass a literal $HOME prefix; Home Manager passes evaluated XDG
  paths. No user identity or interactive shell state belongs in these defaults.
*/
{ cacheHome, stateHome }:
{
  # X11/XWayland clients need XIM even when native Wayland input is enabled.
  # PAM must supply this before systemd-user starts; shell exports are too late.
  XMODIFIERS = "@im=fcitx";
  SDL_IM_MODULE = "fcitx";
  XCOMPOSECACHE = "${cacheHome}/X11/compose";
  XAUTHORITY = "${stateHome}/X11/Xauthority";
  CUDA_CACHE_PATH = "${cacheHome}/nvidia/ComputeCache";
  GLFW_IM_MODULE = "ibus";
  MOZ_ENABLE_WAYLAND = "1";
  NIXOS_OZONE_WL = "1";
  WLR_NO_HARDWARE_CURSORS = "1";
}
