{
  notificationDaemon,
  pkgs,
  ...
}:

# Wayland-native tools used by the Sway desktop session.
with pkgs;
[
  ironbar # Rust and GTK4 panel for Sway, including workspace and system-info modules.
  # Build upstream wayshot with the merged BGR888 stride fix before nixpkgs
  # updates its older 1.4.6 package.
  (callPackage ../pkgs/wayshot.nix { })
  # Provides wl-copy/wl-paste and wl-clip, which is similar to xclip on Wayland.
  wl-clipboard-rs
  # Used to send Ctrl+V after selecting a Clipcat item from the menu.
  (callPackage ../pkgs/wdotool.nix { })
  awww # Rust wallpaper daemon used by Waytrogen.
  notificationDaemon # Patched Rust notification daemon with readable action buttons.
]
