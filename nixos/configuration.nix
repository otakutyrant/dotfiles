{
  lib,
  ...
}:

let
  # Discover Nix modules recursively so related options can live in category
  # directories without maintaining another hard-coded import list. Attribute
  # names returned by attrNames are sorted, so evaluation remains deterministic.
  importModules =
    dir:
    let
      entries = builtins.readDir dir;
    in
    lib.concatMap (
      name:
      let
        path = dir + "/${name}";
        type = entries.${name};
      in
      if type == "directory" then
        importModules path
      else if type == "regular" && lib.hasSuffix ".nix" name then
        [ path ]
      else
        [ ]
    ) (builtins.attrNames entries);
in
{
  imports = [ ./hardware-configuration.nix ] ++ importModules ./modules ++ importModules ./options;

  # Keep the compatibility baseline explicit when configuration is reorganized.
  system.stateVersion = "26.05";
}
