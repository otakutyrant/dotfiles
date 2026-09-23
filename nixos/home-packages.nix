{
  inputs,
  pkgs,
  pkgs-chatgpt,
  pkgs-unstable,
}:

# Packages installed into the user's Home Manager profile.
with pkgs; # Bring package names from pkgs into scope for the list below.
[
  bash # Seems to be required by home-manager
  # I do not know why `programs.home-manager.enable = true` does not work well,
  # so I have install it explictly.
  home-manager
  # Nushell is intentionally omitted here. Home Manager's
  # `programs.nushell.enable` installs the user-facing shell and NixOS also
  # pulls `pkgs.nushell` into the system closure because it is configured as the
  # login shell in configuration.nix.

  # Utilities

  gh # GitHub client
  git-lfs # a Git extension for large files
  dex # Autostart XDG desktop files.
  # Rust replacement for xdotool. Niri uses its compositor-independent uinput
  # backend, enabled by the group and udev rule in configuration.nix.
  (callPackage ./pkgs/wdotool.nix { })
  # Wayland compatibility and desktop utilities used by the niri session.
  xwayland-satellite

  ## Rust-powered

  ouch # Archiver
  (callPackage ./pkgs/tree.nix { }) # Treer, optimized for document comments
  tokei # Source code lines counter
  page # Pager, based on Neovim
  sd # Steam EDitor, search and replace, an alternative to sed
  vimv # Batch files renamer, using Vim style
  (callPackage ./pkgs/imageflow.nix { }) # Image manipulator, an alternative to imagemagick
  (callPackage ./pkgs/oximedia.nix { }) # Video convertor, an alternative to ffmpeg or mediainfo
  macchina # System information shower, an alternative to lsb-release
  clipcat # Clipboard manager

  # ==== GUI clients

  ## GNOME clients
  nautilus # File manager
  file-roller # GUI Archiver
  baobab # Disk analyser
  gnome-system-monitor # System monitor
  gnome-text-editor # GUI Editor
  papers # Document viewer
  fragments # Bittorrent client

  ## Other GUI Clients
  wpsoffice-cn # Office
  (callPackage ./pkgs/wkeys.nix { }) # Rust on-screen Wayland keyboard
  qbittorrent # Bittorrent client
  wechat # Chat client
  ticktick # Time management client
  qt6Packages.fcitx5-configtool # IME config tool
  (callPackage ./pkgs/nutstore.nix { }) # Sync client

  # ==== Development

  ## Editor
  neovim
  python3Packages.pynvim

  ## Agent
  # Install Kimi Code CLI from MoonshotAI's own flake because it is not
  # provided by the pinned NixOS 26.05 nixpkgs package set. It provides the
  # `kimi` command and replaces the legacy Python-based kimi-cli.
  inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  pkgs-unstable.opencode # Open AI harness
  # ChatGPT desktop app is packaged on a dedicated nixpkgs PR branch.
  pkgs-chatgpt.chatgpt

  ## Database
  postgresql
  prisma-engines # Provides Prisma schema-engine for NixOS.
  prisma-language-server

  ## Python
  python3
  uv # Package Manager

  ## TypeScript
  typescript
  pnpm # NPM package manager
  typescript-language-server
  vscode-langservers-extracted
  tailwindcss-language-server

  ## Rust
  rustup

  ## Lua
  lua
  stylua
  lua-language-server

  ## Nix, note that installing nix causes conflicts, so it is not included here
  nixd
  nixfmt

  ## Yaml
  yamlfmt
  yaml-language-server

  ## TOML
  taplo

  # ==== Miscellanea

  ## Audio
  alsa-lib
  alsa-utils # Contains alsamixer and other audio device tools.
  pavucontrol # PulseAudio volume control.
  pulseaudio # Provides PulseAudio CLI tools.
  python3Packages.sounddevice # Suppresses unnecessary ALSA errors in some Python audio tools.

  ## Others
  scowl # English words
  waytrogen # Rust wallpaper chooser for Wayland
  awww # Rust wallpaper daemon used by Waytrogen.
  wired # Rust notification daemon (command: wired)
  ironbar # Rust status bar with native niri workspace support.
  nwg-displays # ARandR-like GUI with native niri output support.
  # `openai-whisper` is accurate, but it brings a heavier Python stack and does not support GPU.
  # `whisper-ctranslate2` can be fast, but its Python/CUDA dependency surface is larger.
  # `whisperx` is useful for word timestamps and diarization, but it is overkill for normal SRT files.
  # `whisper-cpp-vulkan` is a useful non-CUDA fallback, but CUDA is better for this NVIDIA machine.
  (whisper-cpp.override {
    cudaSupport = true;
  })
]
