{ lib, pkgs }:

let
  localPackages = {
    nutstore = pkgs.callPackage ./pkgs/nutstore.nix { };
    nfcloud = pkgs.callPackage ./pkgs/nfcloud.nix { };
  };

  resolvePackage =
    name:
    if builtins.hasAttr name localPackages then
      localPackages.${name}
    else
      lib.attrByPath (lib.splitString "." name) null pkgs;

  pick =
    names:
    map (
      name:
      let
        pkg = builtins.tryEval (resolvePackage name);
      in
      if pkg.success && pkg.value != null then
        pkg.value
      else
        throw "Package `${name}` could not be resolved in nixpkgs"
    ) names;
in
{
  system = pick [
    # Filesystems and navigation
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

    # System information
    "lsb-release" # Show what the linux distribution is.

    # Archives
    "bzip2"
    "gzip"
    "p7zip"
    "gnutar"
    "unrar"
    "unzip"
    "xz"
    "zip"

    # Audio
    "alsa-lib" # Advanced Linux Sound Architecture library.
    "alsa-utils" # Contains alsamixer and other audio device tools.
    "pavucontrol" # PulseAudio volume control.
    "pulseaudioFull" # Provides PulseAudio CLI tools.

    # Bluetooth
    "bluez" # Provides bluetoothctl for fallback CLI pairing/debugging.

    # Shells and terminal basics
    "bash"
    "zsh"
    "nushell"
    "tmux" # Terminal multiplexer.
    "stow" # Dotfiles manager.
    "xdg-user-dirs" # Generate common user directories.

    # Editor runtime
    "python3Packages.pynvim"
  ];

  home = pick [
    # Build tools
    "cmake" # Build system used by native tools and plugins.
    "gcc" # Compiler used by native tools and plugins.
    "gnumake" # Make implementation used by native tools and plugins.
    "pkg-config" # Library discovery helper used by native builds.
    "openssl" # TLS/SSL toolkit and libraries used by native builds.

    # Development utilities
    "prettier" # Formatter for html, css, json, yaml, markdown, typescript.
    "tree-sitter" # CLI used by nvim-treesitter to build/update parsers.
    "cloc" # Code analysis.
    "page" # Pager powered by Neovim.
    "tldr" # Document reader.
    "vimv" # Rename multiple files, written in Rust.
    "sd" # Search and replace.
    "file"
    "git-lfs"
    "home-manager"
    "nil"
    "nixfmt"
    "codex"

    # Python
    "python3"
    "python3Packages.ipython" # Better REPL.
    "python3Packages.pip" # Package manager.
    "uv" # Fast Python package manager.
    "ruff" # Linter and formatter.
    "pyright" # Language server and type checker.
    "basedpyright" # Python language server used by Neovim.

    # Frontend
    "eslint" # ESLint library used by vscode-langservers-extracted.
    "vscode-langservers-extracted"
    "pnpm" # Package manager for Node projects and local LSP dependencies.
    "typescript" # Provides tsserver for typescript-tools.nvim.
    "typescript-language-server"
    "tailwindcss-language-server"
    "postgresql" # Provides psql/createdb for local Prisma PostgreSQL projects.
    "prisma-engines" # Provides Prisma schema-engine for NixOS.
    "prisma-language-server"

    # Rust
    "rustc"
    "cargo"

    # Lua
    "lua"
    "stylua"
    "lua-language-server"

    # Shells and data formats
    "bash-language-server"
    "shellcheck"
    "yamlfmt"
    "yaml-language-server"
    "taplo"

    # AI and media
    "whisper-cpp" # Transcribe.
    "ffmpeg"
    "mediainfo" # View information about media files.
    "python3Packages.sounddevice" # Suppresses unnecessary ALSA errors in some Python audio tools.

    # Reference data
    "scowl" # International words files for /usr/share/dict.

    # Desktop applications
    "google-chrome"
    "polkit_gnome" # Authentication agent for privileged desktop actions.
    "qbittorrent"
    "feh"
    "maim" # X11 screenshot tool.
    "diodon" # GTK clipboard manager with tray and history menu.
    "libnotify" # Provides notify-send.
    "nautilus"
    "file-roller"
    "baobab"
    "gnome-system-monitor"
    "wpsoffice-cn"
    "onboard"
    "nutstore"
    "nfcloud"
    "fragments"
    "goldendict-ng"
    "obs-studio"
    "gedit"
    "calibre"
    "variety"
    "anki"
    "clash-verge-rev"
    "mpv"
    "wechat"
    "papers"
    "ticktick"
    "nitrogen" # Wallpaper manager.

    # X11 desktop
    "arandr"
    "xinit"
    "qt6Packages.fcitx5-configtool" # GUI configuration tool for Fcitx5.
    "xfce4-notifyd"
    "dex" # Autostart XDG desktop files.
    "kitty"
    "picom"
    "gimp"
    "xclip"
  ];
}
