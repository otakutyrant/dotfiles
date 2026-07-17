{
  config,
  hostname,
  lib,
  pkgs,
  username,
  ...
}:

let
  corePackages = import ./core-packages.nix { inherit lib pkgs; };
  pick =
    names:
    builtins.filter (pkg: pkg != null) (
      map (name: lib.attrByPath (lib.splitString "." name) null pkgs) names
    );
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  nix.settings = {
    max-jobs = 4;
    cores = 8;

    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos-cuda.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

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
    shell = pkgs.nushell;
  };

  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;

  programs.git.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
  };
  programs.nix-ld.enable = true;
  programs.npm.enable = true;
  programs.steam.enable = true;

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

  services.earlyoom.enable = true;

  services.displayManager.defaultSession = "none+i3";
  services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.autoLogin = {
    enable = false;
    user = username;
  };

  services.libinput.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  # GUI Bluetooth manager for pairing devices from i3.
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

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
    "noto-fonts-color-emoji"
    "nerd-fonts.jetbrains-mono"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Include vendor firmware that Bluetooth/Wi-Fi adapters may need.
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # Better Bluetooth support for Xbox-compatible controllers, including 8BitDo XInput mode.
  hardware.xpadneo.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = corePackages ++ [
    # Build tools for compiling local/native software, including Neovim plugins.
    pkgs.cmake
    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
    # Provides bluetoothctl for fallback CLI pairing/debugging.
    pkgs.bluez
    pkgs.pavucontrol
    pkgs.pulseaudio
    pkgs.qt6Packages.fcitx5-configtool
  ];

  fileSystems."/run/media/${username}/Shared" = {
    device = "/dev/disk/by-uuid/6FB7-A952";
    fsType = "exfat";
    options = [
      "nofail"
      "rw"
      "uid=1000"
      "gid=100"
      "umask=0002"
      "x-gvfs-show"
    ];
  };

  # Udev rules for non-root access to common game controllers.
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  # Windows shares the ESP with NixOS, so systemd-boot detects it automatically.
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.availableKernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
