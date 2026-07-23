{ pkgs }:

# Packages installed into the user's Home Manager profile.
with pkgs; # Bring package names from pkgs into scope for the list below.
[
  # Shell
  bash
  nushell

  # Audio.
  alsa-lib
  alsa-utils # Contains alsamixer and other audio device tools.
  pavucontrol # PulseAudio volume control.
  pulseaudio # Provides PulseAudio CLI tools.

  # Archives.
  gnutar
  ouch # Human-friendly archive compress/decompress/list frontend.

  # Network
  curl
  wget
  iputils
  openssh
  rsync

  # File manager
  tree

  # Building
  cmake
  gcc
  gnumake
  pkg-config

  # Development utilities.
  prettier
  tree-sitter
  cloc
  page
  tldr
  # Rename multiple files, written in Rust.
  vimv
  # Search and replace.
  sd
  file
  git-lfs
  codex
  neovim
  python3Packages.pynvim

  # Python
  python3
  python3Packages.ipython
  python3Packages.pip
  uv
  ruff
  basedpyright

  # Frontend
  eslint
  vscode-langservers-extracted
  pnpm
  typescript
  typescript-language-server
  tailwindcss-language-server
  postgresql

  # Prisma
  # Provides Prisma schema-engine for NixOS.
  prisma-engines
  prisma-language-server

  # Rust
  rustup

  # Lua
  lua
  stylua
  lua-language-server

  # Nix
  nixd
  nixfmt

  # Shells and data formats.
  bash-language-server
  shellcheck
  yamlfmt
  yaml-language-server
  taplo

  # Media
  ffmpeg
  mediainfo
  python3Packages.sounddevice # Suppresses unnecessary ALSA errors in some Python audio tools.

  # Miscellanea
  openssl
  scowl # English words
  tmux
  lsb-release
  qbittorrent
  feh
  maim # X11 screenshot tool.
  diodon # GTK clipboard manager with tray and history menu.
  libnotify
  nautilus
  file-roller
  baobab
  gnome-system-monitor
  wpsoffice-cn
  onboard # Virtual keyboard.
  (callPackage ./pkgs/nutstore.nix { }) # Local Nutstore desktop sync client derivation.
  (callPackage ./pkgs/nfcloud.nix { }) # Local NFCLOUD desktop client derivation.
  fragments # Bittorrent client
  goldendict-ng
  gnome-text-editor
  variety # Wallpaper manager.
  clash-verge-rev
  wechat
  papers # Document viewer
  ticktick
  arandr
  qt6Packages.fcitx5-configtool
  xfce4-notifyd
  dex # Autostart XDG desktop files.
  kitty
  gimp # Image editor
  xclip
  whisper-cpp # AI and media.
]
