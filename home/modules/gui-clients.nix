{
  config,
  pkgs,
  ...
}:

let
  withFcitxQt = pkgs.callPackage ../../lib/wrap-with-fcitx-qt.nix { };
in
{
  # GUI applications that do not belong to the GNOME client group.
  home.packages = [
    config.programs.kitty.package # GPU-accelerated terminal emulator.
    pkgs.walker # Rust/Wayland application launcher and dmenu-compatible picker.
    (withFcitxQt {
      package = pkgs.wpsoffice-cn;
      executables = [
        "et"
        "wpp"
        "wps"
        "wpspdf"
      ];
    }) # Qt office suite; Sway needs Fcitx's Qt input module.
    pkgs.local.wkeys # On-screen Wayland keyboard, Rust-powered.
    (withFcitxQt {
      package = pkgs.wechat;
      executables = [ "wechat" ];
    }) # WeChat bundles the Fcitx Qt plugin but only enables it via QT_IM_MODULE.
    pkgs.ticktick # Time management client.
    (withFcitxQt {
      package = pkgs.qt6Packages.fcitx5-configtool;
      executables = [
        "fcitx5-config-qt"
        "fcitx5-migrator"
        "kbd-layout-viewer5"
      ];
    }) # Qt configuration interfaces need the same Sway-specific override.
    pkgs.local.nutstore # Sync client.
    pkgs.waytrogen # Wallpaper chooser, Rust-powered.
    pkgs.pwvucontrol # Graphical mixer for PipeWire, Rust-powered.
    pkgs.networkmanagerapplet # NetworkManager tray applet and its nm-signal icons.
    pkgs.local.nmrs # GTK4 NetworkManager frontend.

    # Wayland
    pkgs.ironbar # Rust and GTK4 panel for Sway, including workspace and system-info modules.
    pkgs.swayidle # Idle timeout manager used by the Home Manager service.
    pkgs.swaylock # Screen locker invoked by Sway key bindings and idle timeouts.
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
