{
  pkgs,
  ...
}:

# GUI applications that do not belong to the GNOME client group.
with pkgs;
[
  wpsoffice-cn # Office suite.
  (callPackage ../pkgs/wkeys.nix { }) # On-screen Wayland keyboard, Rust-powered.
  wechat # Chat client.
  ticktick # Time management client.
  qt6Packages.fcitx5-configtool # IME config tool.
  (callPackage ../pkgs/nutstore.nix { }) # Sync client.
  waytrogen # Wallpaper chooser, Rust-powered.
  pwvucontrol # Graphical mixer for PipeWire, Rust-powered.
]
