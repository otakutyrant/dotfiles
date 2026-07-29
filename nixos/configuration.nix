# Function arguments.
{
  config,
  hostname,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Set mirrors.
  nix.settings = {
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
    experimental-features = [
      "nix-command" # Enable the new nix ... command family, like `nix shell`.
      "flakes"
    ];
    # Stop flake commands from warning when tracked files have unstaged edits.
    warn-dirty = false;
  };

  # Apply the proxy settings to the Nix daemon, which does not inherit
  # the user's interactive shell environment.
  # `rec { ... }` is a recursive attribute set, so later proxy variables can
  # reuse earlier variables from the same set, such as `NO_PROXY = no_proxy;`,
  # unless `{ ... }` normal attirbute set does not allow it.
  systemd.services.nix-daemon.environment = rec {
    http_proxy = "http://127.0.0.1:21081";
    https_proxy = http_proxy;
    HTTP_PROXY = http_proxy;
    HTTPS_PROXY = http_proxy;
    all_proxy = "socks5://127.0.0.1:21080";
    ALL_PROXY = all_proxy;
    # Nix daemon downloads should use proxies, but local mirrors and cache hosts
    # must stay direct to avoid unnecessary proxy hops.
    no_proxy = builtins.concatStringsSep "," [
      "localhost"
      "127.0.0.1"
      "::1"
      "mirrors.tuna.tsinghua.edu.cn"
      "mirrors.ustc.edu.cn"
      "mirror.sjtu.edu.cn"
    ];
    NO_PROXY = no_proxy;
  };

  # System version
  system.stateVersion = "26.05";

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Keep old generations trimmed automatically so the Nix store does not grow
  # indefinitely.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Boot
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

  # Partitions
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

  # Swap
  # Use compressed in-RAM swap as the first cushion for memory spikes.
  zramSwap = {
    enable = true;
    # Size zram to 50% of physical RAM; it only consumes RAM as pages are stored.
    memoryPercent = 50;
  };
  # Add a disk-backed swap fallback for CUDA/C++ builds that exceed zram.
  swapDevices = [
    {
      device = "/swapfile";
      # Create a 32 GiB swap file; the unit is MiB.
      size = 32768;
    }
  ];

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  # Required by PipeWire for low-latency scheduling.
  security.rtkit.enable = true;

  # Nvidia
  hardware.nvidia = {
    # Enable the DRM kernel modesetting path required by modern compositors,
    # PRIME/offload setups, and smoother early display handoff.
    modesetting.enable = true;
    # Use NVIDIA's open kernel modules. User-space libraries are still
    # proprietary, but the kernel module portion uses the open variant.
    open = true;
    # Install the `nvidia-settings` control panel for inspecting and adjusting
    # NVIDIA driver options from the desktop.
    nvidiaSettings = true;
    # Enable driver-level power management so suspend/resume and GPU power states
    # are handled by NVIDIA's power management support.
    powerManagement.enable = true;
    # Use the newest NVIDIA driver package available for the selected kernel.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # Graphics
  hardware.graphics = {
    enable = true;
    # Steam and many games still need this.
    enable32Bit = true;
  };

  # X server
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    videoDrivers = [ "nvidia" ];
    displayManager.lightdm.enable = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3lock
        i3status-rust
      ];
    };
  };
  # LightDM starts the X11 session. Auto-login stays disabled so the session
  # requires an explicit login.
  services.displayManager.defaultSession = "none+i3";
  services.displayManager.autoLogin = {
    enable = false;
    user = username;
  };

  # i18n
  i18n.defaultLocale = "en_US.UTF-8";
  # IME
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
    ];
  };

  # Fonts
  # `with pkgs;` lets the list use package names without repeating `pkgs.`.
  fonts.packages = with pkgs; [
    sarasa-gothic
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Bluetooth
  # Include vendor firmware that Bluetooth/Wi-Fi adapters may need.
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    # Start when boot
    powerOnBoot = true;
  };
  # Better Bluetooth support for Xbox-compatible controllers, including 8BitDo XInput mode.
  hardware.xpadneo.enable = true;
  # A bluetooth manager
  services.blueman.enable = true;

  # Miscellanea
  time.timeZone = "Asia/Shanghai";
  programs.whois.enable = true;
  programs.nix-ld.enable = true;
  programs.steam.enable = true;
  virtualisation.docker.enable = true;
  services.postgresql = {
    enable = true;
    # The project databases are used by Yihui development and integration
    # tests. Prisma resets their schemas, so the app database role must own
    # them instead of only being able to connect.
    ensureDatabases = [
      # NixOS requires a database with the same name as the user when
      # `ensureDBOwnership = true` is enabled for that PostgreSQL role.
      username
      "ci_development"
      "ci_test"
    ];
    ensureUsers = [
      {
        name = username;
        ensureClauses.createdb = true;
        # This grants ownership of the same-name database above. It does not
        # cover custom project database names like ci_development or ci_test.
        ensureDBOwnership = true;
      }
    ];
  };
  # `ensureDBOwnership` only handles the same-name database required by the
  # NixOS PostgreSQL module. These two project databases have custom names, so
  # repair their ownership explicitly each time PostgreSQL starts. The commands
  # are idempotent: running ALTER DATABASE OWNER repeatedly is harmless.
  systemd.services.postgresql.postStart = ''
    psql --dbname postgres --command 'ALTER DATABASE "ci_development" OWNER TO "${username}";'
    psql --dbname postgres --command 'ALTER DATABASE "ci_test" OWNER TO "${username}";'
  '';
  # Udev rules for non-root access to common game controllers.
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];
  # Kill runaway processes before the kernel's OOM killer makes the desktop
  # unresponsive.
  services.earlyoom.enable = true;
  # Keep sudo password-protected for wheel users, and enable polkit so GUI tools
  # can request elevated permissions through the authentication agent.
  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;
  # Make Linux support input devices like touchpads and touchscreens.
  services.libinput.enable = true;
  # Let GTK/GNOME apps access more file systems.
  services.gvfs.enable = true;
  # Provide the Freedesktop portal DBus service for lightweight i3 sessions.
  # Toolkits such as GLFW query this service for desktop settings; without an
  # activatable portal backend, clients like Kitty print startup warnings.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    # i3 is not a full desktop environment, so choose the GTK backend as the
    # generic implementation for portal interfaces.
    config.common.default = [ "gtk" ];
  };
  # Make normal desktop apps mount, unmount, and inspect disks better.
  services.udisks2.enable = true;
  # Thumbnails for file managers.
  services.tumbler.enable = true;
  # Clipboard history backend used by Diodon.
  services.zeitgeist.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    # NixOS must install this package because the user account's login shell
    # points at its `bin/nu` executable. Do not also list `nushell` in
    # home-packages.nix; Home Manager's Nushell module handles the user profile
    # side, while this option handles the system login-shell side.
    shell = pkgs.nushell;
  };
}
