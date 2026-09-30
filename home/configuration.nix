{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  home = config.home.homeDirectory;
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
  # Evaluate every category module and focused option module as one profile.
  imports = importModules ./modules ++ importModules ./options;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # Session PATH additions. These used to be added by Nushell startup files, but
  # they are useful to programs launched outside Nushell too.
  home.sessionPath = [
    "${home}/.local/bin"
    "${config.home.profileDirectory}/bin"
    "${home}/.local/share/cargo/bin"
  ];

  # Set an explicit cursor theme because Sway is not a full desktop environment.
  # Keep the X11 link enabled so Xwayland clients use the same cursor theme.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
