{ pkgs }: with pkgs;
[
  # File manager
  tree

  # Network
  curl
  wget
  iputils
  openssh
  rsync

  # Miscellanea
  lsb-release

  # Archives.
  gnutar
  # Human-friendly archive compress/decompress/list frontend.
  ouch

  # Audio.
  alsa-lib
  # Contains alsamixer and other audio device tools.
  alsa-utils
  # PulseAudio volume control.
  pavucontrol
  # Provides PulseAudio CLI tools.
  pulseaudio

  # Bluetooth.
  # `hardware.bluetooth.enable` installs the BlueZ Bluetooth stack.

  # Shell
  bash
  nushell
  stow

  # Editor runtime.
  python3Packages.pynvim
]
