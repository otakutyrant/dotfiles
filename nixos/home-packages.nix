{ inputs, pkgs }:

# Packages installed into the user's Home Manager profile.
with pkgs; # Bring package names from pkgs into scope for the list below.
[
  # Shell
  bash
  # I do not know why `programs.home-manager.enable = true` does not work well,
  # so I have install it explictly.
  home-manager
  # Nushell is intentionally omitted here. Home Manager's
  # `programs.nushell.enable` installs the user-facing shell and NixOS also
  # pulls `pkgs.nushell` into the system closure because it is configured as the
  # login shell in configuration.nix.

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
  # Install Kimi CLI from MoonshotAI's own flake because it is not provided by
  # the pinned NixOS 26.05 nixpkgs package set.
  inputs.kimi-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
  neovim
  python3Packages.pynvim

  # Python
  python3
  python3Packages.ipython
  python3Packages.pip
  uv
  ruff
  basedpyright
  poethepoet # Provides the `poe` task runner command for pyproject.toml tasks.

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
  imagemagick # Provides `magick`, which the image resize daemon uses to inspect and resize images.
  mediainfo
  python3Packages.sounddevice # Suppresses unnecessary ALSA errors in some Python audio tools.

  # Miscellanea
  openssl
  scowl # English words
  tmux
  lsb-release
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
  nitrogen # Wallpaper manager
  clash-verge-rev
  wechat
  papers # Document viewer
  ticktick
  arandr
  qt6Packages.fcitx5-configtool
  xfce4-notifyd
  dex # Autostart XDG desktop files.
  gimp # Image editor
  xclip
  # `openai-whisper` is accurate, but it brings a heavier Python stack.
  # `whisper-ctranslate2` can be fast, but its Python/CUDA dependency surface is larger.
  # `whisperx` is useful for word timestamps and diarization, but it is overkill for normal SRT files.
  # `whisper-cpp-vulkan` is a useful non-CUDA fallback, but CUDA is better for this NVIDIA machine.
  (whisper-cpp.override {
    cudaSupport = true;
  })
]
