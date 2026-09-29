{
  notificationDaemon,
  pkgs,
  pkgs-unstable,
}:

# Compose focused package groups into the user's Home Manager profile.
builtins.concatLists [
  (import ./modules/home-manager.nix { inherit pkgs; })
  (import ./modules/cli-utilities.nix { inherit pkgs; })
  (import ./modules/general-cli.nix { inherit pkgs pkgs-unstable; })
  (import ./modules/media-tools.nix { inherit pkgs; })
  (import ./modules/wayland-tools.nix { inherit notificationDaemon pkgs; })
  (import ./modules/gnome-clients.nix { inherit pkgs; })
  (import ./modules/other-gui-clients.nix { inherit pkgs; })
  (import ./modules/development.nix { inherit pkgs pkgs-unstable; })
  (import ./modules/miscellanea.nix { inherit pkgs; })
]
