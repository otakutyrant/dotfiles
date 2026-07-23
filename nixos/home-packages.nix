{ pkgs }:

# Packages installed into the user's Home Manager profile.
with pkgs; # Bring package names from pkgs into scope for the list below.
[
  # Building
  cmake
  gcc
  gnumake
  pkg-config

  openssl

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

  # Python.
  python3
  python3Packages.ipython
  python3Packages.pip
  uv
  ruff
  basedpyright

  # Frontend.
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

  # Rust.
  rustup

  # Lua.
  lua
  # Include the package `stylua`.
  stylua
  # Include the package `lua-language-server`.
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

  # AI and media.
  whisper-cpp

  # Media
  ffmpeg
  mediainfo
  # Suppresses unnecessary ALSA errors in some Python audio tools.
  python3Packages.sounddevice

  # English words
  scowl

  # Desktop applications.
  qbittorrent
  feh
  # X11 screenshot tool.
  maim
  # GTK clipboard manager with tray and history menu.
  diodon
  libnotify
  nautilus
  file-roller
  baobab
  gnome-system-monitor
  wpsoffice-cn
  # Virtual keyboard.
  onboard
  # Local Nutstore desktop sync client derivation.
  (callPackage ./pkgs/nutstore.nix { })
  # Local NFCLOUD desktop client derivation.
  (callPackage ./pkgs/nfcloud.nix { })
  # Bittorrent client
  fragments
  goldendict-ng
  gnome-text-editor
  # Wallpaper manager.
  variety
  clash-verge-rev
  wechat
  # Document viewer
  papers
  ticktick

  arandr
  qt6Packages.fcitx5-configtool
  xfce4-notifyd
  # Autostart XDG desktop files.
  dex
  kitty
  # Image editor
  gimp
  xclip
]
