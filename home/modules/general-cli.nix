{
  pkgs,
  pkgs-unstable,
  ...
}:

# General-purpose command-line tools, mostly built with Rust.
with pkgs;
[
  page # Pager, based on Neovim.
  ouch # Archiver.
  vimv # Batch files renamer, using Vim style.
  tokei # Source code lines counter.
  (callPackage ../pkgs/tree.nix { }) # Treer, optimized for document comments.
  sd # Steam EDitor, search and replace, an alternative to sed.
  macchina # System information shower, an alternative to lsb-release.
  clipcat # Clipboard manager, an alternative to doidon.
  # Use the current rqbit release from unstable. Magnet links are submitted
  # separately through its HTTP API because rqbit 9's CLI is stateless.
  pkgs-unstable.rqbit # BitTorrent client, an alternative to Fragments or qBittorrent.
]
