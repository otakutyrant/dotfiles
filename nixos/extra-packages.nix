{ lib, pkgs }:

let
  # Keep package names aligned with cli_clients.txt and gui_clients.txt. When an
  # Arch package name differs from the Nixpkgs attribute, translate it here.
  packageAliases = {
    "page-git" = "page";
    "python" = "python3";
    "ipython" = "python3Packages.ipython";
    "python-pip" = "python3Packages.pip";
    "eslint-language-server" = "vscode-langservers-extracted";
    "rust" = "rustc";
    "cuda" = "cudaPackages.cudatoolkit";
    "cudnn" = "cudaPackages.cudnn";
    "python-pytorch-opt-cuda" = "python3Packages.torchWithCuda";
    "tensorboard" = "python3Packages.tensorboard";
    "whisper-git" = "whisper-cpp";
    "python-sounddevice" = "python3Packages.sounddevice";
    "words" = "scowl";
    "fcitx5-im" = "fcitx5";
    "wps-office" = "wpsoffice-cn";
    "goldendict-ng-git" = "goldendict-ng";
    "xorg-xinit" = "xinit";
    "pkgfile" = "nix-index";
    "fcitx5-configtool" = "qt6Packages.fcitx5-configtool";
    "nutstore" = pkgs.callPackage ./pkgs/nutstore.nix { };
  };
  resolvePackage =
    name:
    let
      resolved = packageAliases.${name} or name;
    in
    if builtins.isString resolved then
      lib.attrByPath (lib.splitString "." resolved) null pkgs
    else
      resolved;
  pick =
    names:
    # Use the Nixpkgs attribute name when an alias exists; otherwise try
    # the original package name.
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
pick [
  # Development
  # General
  "cmake" # build system used by native tools and plugins
  "gcc" # compiler used by native tools and plugins
  "gnumake" # make implementation used by native tools and plugins
  "pkg-config" # library discovery helper used by native builds
  "prettier" # formatter for html, css, json, yaml, markdown, typescript
  "tree-sitter" # CLI used by nvim-treesitter to build/update parsers.
  "cloc" # code analysis
  "page-git" # pager powered by neovim
  "tldr" # document reader
  "vimv" # rename multiple files, written in Rust

  # Python
  "python"
  "ipython" # better repl
  "python-pip" # package manager
  "uv" # supreme package manager
  "ruff" # linter and formatter. I am not sure what ruff-python is for.
  "pyright" # ls and type checker
  "basedpyright" # Python ls used by Neovim.

  # Front End
  "eslint" # ESLint library used by vscode-eslint-language-server.
  "eslint-language-server"
  "pnpm" # Package manager for Node projects and their local LSP dependencies.
  "typescript" # Provides tsserver for typescript-tools.nvim.
  "typescript-language-server"
  "tailwindcss-language-server"
  "prisma-language-server"

  # Rust
  "rust"
  "cargo" # package manager

  # Lua
  "lua"
  "stylua" # formatter
  "lua-language-server"

  # Others
  "yamlfmt" # yaml formatter
  "taplo" # toml formatter

  # Arch Linux
  "pkgfile" # List what package a file belong to.
  "arch-install-scripts" # Scripts to aid in installing Arch Linux

  # AI
  "whisper-git" # Transcribe

  # Media
  "ffmpeg"
  "mediainfo" # Viewing information about media files

  # Audio
  "python-sounddevice" # Importing this in Python can suppress unnecessary ALSA errors, see https://github.com/Uberi/speech_recognition/issues/182#issuecomment-2625391270

  # Others
  "words" # A collection of International 'words' files for /usr/share/dict.
  "sd" # Search and replace.
  "codex"
  "file"
  "git-lfs"
  "home-manager"
  "nil"
  "nixfmt"
  "bash-language-server"
  "shellcheck"
  "yaml-language-server"
  "xclip"

  # GUI
  "google-chrome" # Web Browser
  "polkit_gnome" # Authentication agent for privileged desktop actions.
  "qbittorrent" # BitTorrent clients
  "feh" # Image viewer
  "scrot" # Screenshot
  "nautilus" # File Manager
  "file-roller" # Archive Manager
  "baobab" # Disk usage display
  "gnome-system-monitor" # System monitoring
  "wpsoffice-cn" # Office suites
  "onboard" # On-screen keyboard
  "nutstore" # Cloud backup
  "goldendict-ng-git" # Dictionary
  "obs-studio" # Screen Recording
  "gedit" # Editor
  "calibre" # E-Book Manager
  "variety" # Wallpaper Manager
  "anki" # Flashcards
  "clash-verge-rev" # Proxy
  "mpv" # video/audio player
  "wechat"
  "papers" # GNOME next-generation PDF Viewer
  "ticktick" # To-do list
  "nitrogen" # Wallpapers mamanger

  # X11
  "arandr"
  "xorg-xinit"
  "fcitx5-configtool" # GUI configuration tool for Fcitx5.
  "xfce4-notifyd"
  "dex" # Autostart XDG desktop files
  "kitty"
  "picom"
  "gimp"
]
++ [
  (pkgs.callPackage ./pkgs/nfcloud.nix { })
]
