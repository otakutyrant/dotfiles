{
  pkgs,
  ...
}:

# GTK and GNOME applications used as the primary desktop clients.
with pkgs;
[
  nautilus # File manager.
  file-roller # GUI archiver.
  baobab # Disk analyser.
  gnome-system-monitor # System monitor.
  gnome-text-editor # GUI editor.
  papers # Document viewer.
]
