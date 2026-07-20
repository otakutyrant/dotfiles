{
  config,
  hostname,
  lib,
  pkgs,
  username,
  ...
}:

let
  packages = import ./packages.nix { inherit lib pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./modules.nix
  ];

  networking.hostName = hostname;

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

  environment.systemPackages = packages.system;

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
