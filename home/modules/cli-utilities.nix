{
  pkgs,
  ...
}:

# Small command-line and desktop integration utilities used across workflows.
with pkgs;
[
  gh # GitHub client.
  git-lfs # A Git extension for large files.
  file # Joshuto uses this command to detect file types and MIME types.
  (callPackage ../pkgs/nur.nix { }) # Nur task runner used by this repository.
  walker # Rust/Wayland application launcher and dmenu-compatible picker.
  networkmanagerapplet # NetworkManager tray applet and its nm-signal icons.
  (callPackage ../pkgs/nmrs.nix { }) # GTK4 NetworkManager frontend.
]
