{ lib, pkgs }:

let
  pick =
    names:
    map (
      name:
      let
        pkg = builtins.tryEval (lib.attrByPath (lib.splitString "." name) null pkgs);
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
  "gvfs" # Virtual filesystem implementation for GIO, including MTP and SMB.
  "ntfs3g" # Microsoft Windows filesystem NTFS.

  # Network
  "curl"
  "wget"
  "iputils"
  "openssh"
  "rsync"
  "whois"

  # Development
  # General
  "python3Packages.pynvim" # editor

  # Operation System
  "lsb-release" # Show what the linux distribution is.

  # Archiving and Compression Tools
  "bzip2"
  "gzip"
  "p7zip"
  "gnutar"
  "unrar"
  "unzip"
  "xz"
  "zip"

  # Audio
  "alsa-lib" # Advanced Linux Sound Architecture. Providing kernel driven sound card drivers
  "alsa-utils" # Containing alsamixer, an interface for audio device configuration.
  "pavucontrol" # PulseAudio volume control.
  "pulseaudioFull" # Provides PulseAudio CLI tools.

  # Bluetooth
  "bluez" # Provides bluetoothctl for fallback CLI pairing/debugging.

  # Others
  "xdg-user-dirs" # Generate common user directories.
  "stow" # Dofiles mamanger
  "tmux" # Terminal Multiplexer
  "bash" # Shell
  "zsh" # Shell
  "nushell" # Shell
]
