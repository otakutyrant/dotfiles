{ lib, pkgs }:

let
  # When an Arch package name differs from the Nixpkgs attribute, translate it
  # here before lookup.
  packageAliases = {
    "gvfs-mtp" = "gvfs";
    "gvfs-smb" = "gvfs";
    "ntfs-3g" = "ntfs3g";
    "python-pynvim" = "python3Packages.pynvim";
    "nvidia" = "linuxPackages_latest.nvidia_x11";
    "nvidia-utils" = "linuxPackages_latest.nvidia_x11";
    "tar" = "gnutar";
    "alsa" = "alsa-lib";
  };
  pick =
    names:
    # Use the Nixpkgs attribute name when an alias exists; otherwise try
    # the original package name. Missing/removed packages are filtered out.
    builtins.filter (pkg: pkg != null) (
      map (
        name:
        let
          resolvedName = packageAliases.${name} or name;
          pkg = builtins.tryEval (lib.attrByPath (lib.splitString "." resolvedName) null pkgs);
        in
        if pkg.success then pkg.value else null
      ) names
    );
in
pick [
  # File Navigator
  "tree"
  "gvfs-mtp" # Virtual filesystem implementation for GIO (Android, media player).
  "gvfs-smb" # For SMB protocol.
  "ntfs-3g" # Microsoft Windows filesystem NTFS.
  "fd" # Simple, fast and user-friendly alternative to find.
  "zoxide" # jump tool

  # Network
  "curl"
  "wget"
  "iputils"
  "networkmanager"
  "openssh"
  "rsync"
  "whois"

  # Development
  # General
  "neovim" # editor
  "python-pynvim" # editor
  "ripgrep" # grep
  "fzf" # fuzzy search
  "git" # version control

  # Nvidia GPU
  "nvidia"
  "nvidia-utils" # It includes nvidia-smi.

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
