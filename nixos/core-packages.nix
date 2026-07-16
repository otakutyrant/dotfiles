{ lib, pkgs }:

let
  # When an Arch package name differs from the Nixpkgs attribute, translate it
  # here before lookup.
  packageAliases = {
    "gvfs-mtp" = "gvfs";
    "gvfs-smb" = "gvfs";
    "ntfs-3g" = "ntfs3g";
    "python-pynvim" = "python3Packages.pynvim";
    "tar" = "gnutar";
    "alsa" = "alsa-lib";
  };
  pick =
    names:
    # Use the Nixpkgs attribute name when an alias exists; otherwise try
    # the original package name.
    map (
      name:
      let
        resolvedName = packageAliases.${name} or name;
        pkg = builtins.tryEval (lib.attrByPath (lib.splitString "." resolvedName) null pkgs);
      in
      if pkg.success && pkg.value != null then
        pkg.value
      else
        throw "Package `${name}` could not be resolved in nixpkgs"
    ) names;
in
pick [
  # File Navigator
  "tree"
  "gvfs-mtp" # Virtual filesystem implementation for GIO (Android, media player).
  "gvfs-smb" # For SMB protocol.
  "ntfs-3g" # Microsoft Windows filesystem NTFS.

  # Network
  "curl"
  "wget"
  "iputils"
  "openssh"
  "rsync"
  "whois"

  # Development
  # General
  "neovim" # editor
  "python-pynvim" # editor

  # Operation System
  "lsb-release" # Show what the linux distribution is.

  # Archiving and Compression Tools
  "bzip2"
  "gzip"
  "p7zip"
  "tar"
  "unrar"
  "unzip"
  "xz"
  "zip"

  # Audio
  "alsa" # Advanced Linux Sound Architecture. Providing kernel driven sound card drivers
  "alsa-utils" # Containing alsamixer, an interface for audio device configuration.

  # Others
  "xdg-user-dirs" # Generate common user directories.
  "stow" # Dofiles mamanger
  "tmux" # Terminal Multiplexer
  "bash" # Shell
  "zsh" # Shell
  "nushell" # Shell
]
