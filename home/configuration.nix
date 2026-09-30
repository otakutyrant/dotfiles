{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  home = config.home.homeDirectory;
  # Share recursive module discovery with the NixOS configuration.
  importModules = import ../lib/import-modules.nix { inherit lib; };
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
