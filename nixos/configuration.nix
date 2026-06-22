{
  hostname,
  lib,
  pkgs,
  username,
  ...
}:

let
  pick =
    names:
    builtins.filter (pkg: pkg != null) (
      map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names
    );
in
{
  imports = lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix) /etc/nixos/hardware-configuration.nix;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = true;

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.nix-ld.enable = true;

  virtualisation.docker.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3lock
        i3status-rust
      ];
    };
  };

  services.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.autoLogin = {
    enable = false;
    user = username;
  };

  services.libinput.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
    ];
  };

  fonts.packages = pick [
    "sarasa-gothic"
    "jetbrains-mono"
    "noto-fonts"
    "noto-fonts-cjk-sans"
    "noto-fonts-emoji"
    "nerd-fonts.jetbrains-mono"
  ];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = pick [
    "alsa-utils"
    "arandr"
    "baobab"
    "btop"
    "bzip2"
    "calibre"
    "cloc"
    "curl"
    "dex"
    "fd"
    "feh"
    "ffmpeg"
    "file"
    "fzf"
    "gimp"
    "git"
    "git-lfs"
    "gnome-system-monitor"
    "google-chrome"
    "gvfs"
    "i3"
    "i3lock"
    "i3status-rust"
    "iputils"
    "kitty"
    "lua"
    "lua-language-server"
    "mediainfo"
    "mpv"
    "nautilus"
    "networkmanagerapplet"
    "neovim"
    "nil"
    "nixfmt-rfc-style"
    "nodePackages.bash-language-server"
    "nodePackages.prettier"
    "nodePackages.typescript-language-server"
    "nushell"
    "obs-studio"
    "openssh"
    "p7zip"
    "picom"
    "python3"
    "python3Packages.ipython"
    "python3Packages.pynvim"
    "qbittorrent"
    "ripgrep"
    "rofi"
    "rsync"
    "ruff"
    "scrot"
    "shellcheck"
    "steam"
    "stow"
    "stylua"
    "taplo"
    "tldr"
    "tmux"
    "tree"
    "unrar"
    "unzip"
    "uv"
    "wget"
    "whois"
    "xclip"
    "xdg-user-dirs"
    "xorg.xinit"
    "xorg.xrandr"
    "xsel"
    "xz"
    "yaml-language-server"
    "yamlfmt"
    "yazi"
    "yt-dlp"
    "zip"
    "zoxide"
    "zsh"
  ];

  system.stateVersion = "26.05";
}
