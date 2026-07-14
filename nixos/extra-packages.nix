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
    "ttf-sarasa-gothic" = "sarasa-gothic";
    "ttf-jetbrains-mono-nerd" = "nerd-fonts.jetbrains-mono";
    "noto-fonts-emoji" = "noto-fonts-color-emoji";
    "python-sounddevice" = "python3Packages.sounddevice";
    "words" = "scowl";
    "network-manager-applet" = "networkmanagerapplet";
    "fcitx5-im" = "fcitx5";
    "wps-office" = "wpsoffice-cn";
    "goldendict-ng-git" = "goldendict-ng";
    "i3-wm" = "i3";
    "xorg" = "xorg-server";
    "xorg-xinit" = "xinit";
    "pkgfile" = "nix-index";
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
  # Network
  "yt-dlp" # Youtube Downloader

  # Development
  # General
  "prettier" # formatter for html, css, json, yaml, markdown, typescript
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

  # Front End
  "eslint-language-server"
  "typescript-language-server"

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

  # Font
  "ttf-sarasa-gothic" # CJK
  "ttf-jetbrains-mono-nerd"
  "noto-fonts-emoji"

  # Media
  "ffmpeg"
  "mediainfo" # Viewing information about media files

  # Audio
  "pipewire" # Sound server, better than pulseaudio and jack.
  "python-sounddevice" # Importing this in Python can suppress unnecessary ALSA errors, see https://github.com/Uberi/speech_recognition/issues/182#issuecomment-2625391270

  # Others
  "words" # A collection of International 'words' files for /usr/share/dict.
  "sd" # Search and replace.
  "codex"
  "btop"
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
  "steam" # Game, available in multiple repo
  "network-manager-applet" # Tray for Network Manager
  "qbittorrent" # BitTorrent clients
  "feh" # Image viewer
  "scrot" # Screenshot
  "nautilus" # File Manager
  "file-roller" # Archive Manager
  "baobab" # Disk usage display
  "gnome-system-monitor" # System monitoring
  "xsel" # Clipboard manager
  "fcitx5-rime" # Input method editor
  "wpsoffice-cn" # Office suites
  "rofi" # Application launchers
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

  # X11
  "arandr"
  "i3-wm"
  "i3status-rust"
  "xorg"
  "xorg-xinit"
  "xsel" # Copy from CLI clients to system clipboard
  "xfce4-notifyd"
  "dex" # Autostart XDG desktop files
  "kitty"
  "i3lock"
  "picom"
  "gimp"
]
++ [
  (pkgs.callPackage ./pkgs/nfcloud.nix { })
]
