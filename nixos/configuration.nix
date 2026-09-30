{
  lib,
  ...
}:

let
  # Share recursive module discovery with the Home Manager configuration.
  importModules = import ../lib/import-modules.nix { inherit lib; };
in
{
  imports = [ ./hardware-configuration.nix ] ++ importModules ./modules ++ importModules ./options;

  # Keep the compatibility baseline explicit when configuration is reorganized.
  system.stateVersion = "26.05";
}
