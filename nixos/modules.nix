{
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
  # NetworkManager is the normal desktop networking stack here. It provides
  # Wi-Fi/Ethernet management for nm-applet and keeps network setup out of i3.
  networking.networkmanager.enable = true;

  # Keep sudo password-protected for wheel users, and enable polkit so GUI tools
  # can request elevated permissions through the authentication agent.
  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;

  # System-level developer tools and integrations that need NixOS modules, not
  # just packages in PATH.
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

  # Steam needs more than a package: the NixOS module wires runtime libraries,
  # desktop integration, and compatibility settings.
  programs.steam.enable = true;

  # Docker is used for local development and is paired with the user's docker
  # group membership in configuration.nix.
  virtualisation.docker.enable = true;

  # X11 plus i3 is the main graphical session. i3's small companion tools are
  # installed through the window-manager module so they are available to the
  # session even before Home Manager has added user packages.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
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
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.autoLogin = {
    enable = false;
    user = username;
  };

  # Kill runaway processes before the kernel's OOM killer makes the desktop
  # unresponsive.
  services.earlyoom.enable = true;

  # Local PostgreSQL databases for development. The normal user can create and
  # reset databases so project setup scripts and Prisma migrations work without
  # switching to the postgres account.
  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "ci_development"
      "ci_test"
    ];
    ensureUsers = [
      {
        name = username;
        ensureClauses.createdb = true;
      }
    ];
  };

  # Desktop file manager support: libinput for input devices, gvfs/udisks2 for
  # mounting and virtual filesystems, and tumbler for thumbnails.
  services.libinput.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.zeitgeist.enable = true; # Clipboard history backend used by Diodon.

  # GUI Bluetooth manager for pairing devices from i3.
  services.blueman.enable = true;

  # PipeWire provides the audio stack, PulseAudio compatibility, JACK support,
  # and realtime scheduling through rtkit.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Fcitx5 with Rime is the input-method stack. The GTK addon is installed so
  # GTK applications can talk to Fcitx correctly under X11.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
    ];
  };

  # Fonts used by the desktop, terminals, CJK text, emoji, and Nerd Font icons.
  fonts.packages = pick [
    "sarasa-gothic"
    "jetbrains-mono"
    "noto-fonts"
    "noto-fonts-cjk-sans"
    "noto-fonts-color-emoji"
    "nerd-fonts.jetbrains-mono"
  ];

  # Udev rules for non-root access to common game controllers.
  services.udev.packages = [
    pkgs.game-devices-udev-rules
  ];
}
