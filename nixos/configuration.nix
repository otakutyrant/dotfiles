# Function arguments.
{
  hostname,
  pkgs,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # Keep the machine's NVIDIA driver policy separate from the general system
    # configuration so driver updates are easier to review in isolation.
    ./options/nvidia.nix
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
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = http_proxy;
    HTTP_PROXY = http_proxy;
    HTTPS_PROXY = http_proxy;
    all_proxy = "socks5://127.0.0.1:7890";
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
    # wdotool falls back to a virtual kernel input device on niri.
    "uinput"
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
  networking = {
    networkmanager = {
      enable = true;
      # Keep NetworkManager from replacing /etc/resolv.conf with the router's
      # DNS server. Clash Verge TUN mode currently makes DNS queries to the
      # router time out, while public DNS servers are handled by Clash's DNS
      # hijack correctly.
      dns = "none";
    };
    # Use public DNS servers instead of the DHCP-provided router address.
    # The router DNS currently times out under Clash Verge TUN mode.
    nameservers = [
      # AliDNS, run by Alibaba Cloud. Good default DNS inside mainland China.
      "223.5.5.5"
      "223.6.6.6"
      # DNSPod public DNS, run by Tencent. Good mainland China fallback.
      "119.29.29.29"
      # Baidu public DNS. Another China-local fallback.
      "180.76.76.76"
      # Google DNS. Keep it after China-local DNS because it may be blocked or
      # unreliable without Clash/TUN in mainland China.
      "8.8.8.8"
      # Cloudflare DNS. Also useful as a fallback, but may be unreliable without
      # Clash/TUN in mainland China.
      "1.1.1.1"
    ];
    hostName = hostname;
  };

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

  # Graphics
  hardware.graphics = {
    enable = true;
    # Steam and many games still need this.
    enable32Bit = true;
  };
  # This option selects the NVIDIA graphics driver even though no X server is
  # enabled; niri and Xwayland use the same kernel and userspace driver stack.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the Wayland compositor and its session entry for the display manager.
  programs.niri.enable = true;
  # greetd can start the niri Wayland session directly. tuigreet provides a
  # small text login screen while keeping the existing explicit-login policy.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
      user = "greeter";
    };
  };

  # NVIDIA's driver can retain freed compositor buffers and report very high
  # VRAM use. This per-process profile applies niri's documented mitigation.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

  # i18n
  i18n.defaultLocale = "en_US.UTF-8";
  # IME
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      # Add the zhwiki vocabulary used by the synchronized
      # terra_pinyin.extended.dict.yaml dictionary.
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-data
          rime-zhwiki
        ];
      })
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
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "page";
  };
  environment.sessionVariables = {
    # Kitty uses GLFW's IBus client protocol for text-input events. Define this
    # in the login session so compositor-launched Kitty inherits it.
    GLFW_IM_MODULE = "ibus";
    # Prefer native Wayland rendering in Firefox and Chromium/Electron wrappers.
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
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
  # Cthulock authenticates the entered password through this dedicated PAM
  # service. The locker itself comes from its pinned flake in Home Manager.
  security.pam.services.cthulock = { };
  # Make Linux support input devices like touchpads and touchscreens.
  services.libinput.enable = true;
  # Let GTK/GNOME apps access more file systems.
  services.gvfs.enable = true;
  # programs.niri installs and configures the GNOME and GTK portal backends.
  # The GNOME backend is required for screen sharing under niri.
  # Make normal desktop apps mount, unmount, and inspect disks better.
  services.udisks2.enable = true;
  # Thumbnails for file managers.
  services.tumbler.enable = true;
  # Clipboard history backend used by Diodon.
  services.zeitgeist.enable = true;

  # Install Clash Verge through the NixOS module instead of Home Manager, since
  # service mode and TUN mode need system-level privileged helper setup.
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };

  # Give wdotool access only to the virtual input device used by its niri
  # fallback. This avoids granting access to physical keyboards and mice.
  users.groups.uinput = { };
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "docker"
      "networkmanager"
      "uinput"
      "wheel"
    ];
    # NixOS must install this package because the user account's login shell
    # points at its `bin/nu` executable. Do not also list `nushell` in
    # home-packages.nix; Home Manager's Nushell module handles the user profile
    # side, while this option handles the system login-shell side.
    shell = pkgs.nushell;
  };
}
