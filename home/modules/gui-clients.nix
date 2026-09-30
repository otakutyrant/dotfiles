{
  config,
  pkgs,
  ...
}:

{
  # GUI applications that do not belong to the GNOME client group.
  home.packages = [
    config.programs.kitty.package # GPU-accelerated terminal emulator.
    pkgs.walker # Rust/Wayland application launcher and dmenu-compatible picker.
    pkgs.wpsoffice-cn # Office suite.
    pkgs.local.wkeys # On-screen Wayland keyboard, Rust-powered.
    pkgs.wechat # Chat client.
    pkgs.ticktick # Time management client.
    pkgs.qt6Packages.fcitx5-configtool # IME config tool.
    pkgs.local.nutstore # Sync client.
    pkgs.waytrogen # Wallpaper chooser, Rust-powered.
    pkgs.pwvucontrol # Graphical mixer for PipeWire, Rust-powered.
    pkgs.networkmanagerapplet # NetworkManager tray applet and its nm-signal icons.
    pkgs.local.nmrs # GTK4 NetworkManager frontend.

    # Wayland
    pkgs.ironbar # Rust and GTK4 panel for Sway, including workspace and system-info modules.
    # Build upstream wayshot with the merged BGR888 stride fix before nixpkgs
    # updates its older 1.4.6 package.
    pkgs.local.wayshot
    # Provides wl-copy/wl-paste and wl-clip, which is similar to xclip on Wayland.
    pkgs.wl-clipboard-rs
    # Used to send Ctrl+V after selecting a Clipcat item from the menu.
    pkgs.local.wdotool
    pkgs.awww # Rust wallpaper daemon used by Waytrogen.
    pkgs.local.nwg-notifications # Patched notification daemon with readable action buttons.

    # GNOME
    pkgs.nautilus # File manager.
    pkgs.file-roller # GUI archiver.
    pkgs.baobab # Disk analyser.
    pkgs.gnome-system-monitor # System monitor.
    pkgs.gnome-text-editor # GUI editor.
    pkgs.papers # Document viewer.
  ];
}
