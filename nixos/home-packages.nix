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

  # CLI Utilities

  gh # GitHub client
  git-lfs # a Git extension for large files
  dex # Autostart XDG desktop files.
  walker # Rust/Wayland application launcher and dmenu-compatible picker.
  inputs.nmrs.packages.${pkgs.stdenv.hostPlatform.system}.default

  ## Rust-powered

  ### General command-line tools
  page # Pager, based on Neovim
  ouch # Archiver
  vimv # Batch files renamer, using Vim style
  tokei # Source code lines counter
  (callPackage ./pkgs/tree.nix { }) # Treer, optimized for document comments
  sd # Steam EDitor, search and replace, an alternative to sed
  macchina # System information shower, an alternative to lsb-release
  clipcat # Clipboard manager, an alternative to doidon
  rqbit # BitTorrent client, an alternative to Fragments or qBittorrent

  ### Media tools
  (callPackage ./pkgs/imageflow.nix { }) # Image tool, an alternative to ImageMagick.
  (callPackage ./pkgs/oximedia.nix { }) # Video converter, an alternative to ffmpeg or mediainfo.
  wiremix # Rust terminal mixer for stream volumes, routing, and device profiles.

  ### Wayland tools
  wayshot # Rust screenshot capture, for Wayland instead of X11 tools like maim.
  # Provides wl-copy/wl-paste and wl-clip, which is similar to xclip on Wayland.
  wl-clipboard-rs
  # Used to send Ctrl+V after selecting a Clipcat item from the menu.
  (callPackage ./pkgs/wdotool.nix { })
  awww # Rust wallpaper daemon used by Waytrogen.
  wired # Rust notification daemon.

  # ==== GUI clients

  ## GNOME clients
  nautilus # File manager
  file-roller # GUI Archiver
  baobab # Disk analyser
  gnome-system-monitor # System monitor
  gnome-text-editor # GUI Editor
  papers # Document viewer

  ## Other GUI Clients
  wpsoffice-cn # Office
  (callPackage ./pkgs/wkeys.nix { }) # on-screen Wayland keyboard, Rust-powered
  wechat # Chat client
  ticktick # Time management client
  qt6Packages.fcitx5-configtool # IME config tool
  (callPackage ./pkgs/nutstore.nix { }) # Sync client
  waytrogen # Wallpaper chooser, Rust-powered
  pwvucontrol # Graphical mixer for PipeWire, Rust-powered

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

  ## C/C++
  gcc # Provides `cc` for tools that expect a C compiler on PATH.

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

  scowl # English words
  # `openai-whisper` is accurate, but it brings a heavier Python stack and does not support GPU.
  # `whisper-ctranslate2` can be fast, but its Python/CUDA dependency surface is larger.
  # `whisperx` is useful for word timestamps and diarization, but it is overkill for normal SRT files.
  # `whisper-cpp-vulkan` is a useful non-CUDA fallback, but CUDA is better for this NVIDIA machine.
  (whisper-cpp.override {
    cudaSupport = true;
  })
]
