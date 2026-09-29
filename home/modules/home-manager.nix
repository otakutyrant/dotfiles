{
  pkgs,
  ...
}:

# Core tools used by Home Manager itself and by the user's login environment.
with pkgs;
[
  bash # Seems to be required by Home Manager.
  # I do not know why `programs.home-manager.enable = true` does not work well,
  # so I install it explicitly.
  home-manager
]
