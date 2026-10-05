{
  lib,
  pkgs,
  ...
}:

{
  # Enable Sway as a system login session. User-facing helper packages live in
  # Home Manager, while NixOS provides the compositor and session integration.
  programs.sway = {
    enable = true;
    # Stable NixOS 26.05 still provides Sway 1.11. Sway 1.12 re-applies output
    # constraints when GTK repositions a layer-shell popup, keeping Ironbar's
    # sliding tray submenus on-screen above a bottom bar.
    package = pkgs.local.sway;
    extraPackages = [ ];
    extraOptions = [ "--unsupported-gpu" ];
  };

  # Walker uses Elephant as its application and provider backend.
  services.elephant.enable = true;
  # Inherit the user manager's PATH so Elephant can launch desktop entries from
  # both the system and Home Manager profiles.
  systemd.user.services.elephant.environment.PATH = lib.mkForce null;
  # Sway imports its live Wayland environment and restarts Elephant itself.
  systemd.user.services.elephant.wantedBy = [ ];

  # greetd starts the system-provided Sway session after an explicit login.
  services.greetd = {
    enable = true;
    settings.default_session = {
      # Keep greetd on the same Sway package as the NixOS session wrapper.
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd '${pkgs.local.sway}/bin/sway --unsupported-gpu'";
      user = "greeter";
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # Use Wayland text-input coordinates instead of X11 coordinates so the
    # candidate panel follows the cursor across rotated displays.
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      # Include the zhwiki vocabulary imported by the extended Rime dictionary.
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-data
          rime-zhwiki
        ];
      })
      fcitx5-gtk
    ];
  };

  fonts.packages = with pkgs; [
    sarasa-gothic
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Steam needs system-level graphics integration, udev rules, and libraries.
  programs.steam.enable = true;

  # Install LocalSend through its NixOS module. Its firewall opening remains
  # disabled because networking.nix restricts the port to the Wi-Fi interface.
  programs.localsend.enable = true;

  # Install Clash Verge through NixOS because service and TUN modes require a
  # privileged helper that cannot be configured solely through Home Manager.
  programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    autoStart = true;
  };

  # Desktop infrastructure shared by graphical applications in the Sway
  # session. These are system D-Bus or hardware-facing services.
  services.libinput.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.zeitgeist.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = [ "gtk" ];
    # Override Sway's GTK-only default so screen sharing uses wlroots first.
    config.sway.default = lib.mkForce [
      "wlr"
      "gtk"
    ];
  };
}
