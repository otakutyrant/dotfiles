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
  # This is a preference consumed only by Home Manager modules that explicitly
  # support it, such as the Codex and npm modules; it is not a global XDG mode
  # and does not export the XDG base-directory variables. env.nix exports those
  # separately. Applications outside the supporting modules still need their
  # own environment variable, command wrapper, or compatibility path, so this
  # option alone cannot keep the home directory free of legacy dotfiles.
  home.preferXdgDirectories = true;

  # Session PATH additions. These used to be added by Nushell startup files, but
  # they are useful to programs launched outside Nushell too.
  home.sessionPath = [
    "${home}/.local/bin"
    "${config.home.profileDirectory}/bin"
    "${home}/.local/share/cargo/bin"
    "${config.xdg.dataHome}/go/bin"
  ];

  # Set an explicit cursor theme because Sway is not a full desktop environment.
  # Xwayland clients inherit XCURSOR_THEME and XCURSOR_SIZE; avoid generating
  # legacy ~/.Xresources and ~/.icons copies for the same theme.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    dotIcons.enable = false;
  };
}
