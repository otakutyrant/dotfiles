{ lib }:

let
  # Return every regular Nix file below a directory. Directories and attribute
  # names are traversed in sorted order so module evaluation is deterministic.
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
importModules
