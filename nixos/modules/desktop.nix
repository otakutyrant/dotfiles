{
  config,
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

  # A graphical greeter keeps login readable at the center display's native
  # resolution. Its isolated Sway config must not start user-session services.
  programs.regreet = {
    enable = true;
    # Keep the reference layout in ReGreet: a transparent left column with a
    # large clock above the form. CSS alone cannot change GTK alignments.
    package = pkgs.regreet.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../files/greetd/regreet-layout.patch ];
    });
    font = {
      package = pkgs.local.sarasa-fixed-sc;
      name = "Sarasa Fixed SC";
      size = 16;
    };
    extraCss = ../files/greetd/regreet.css;
    settings = {
      GTK.application_prefer_dark_theme = true;
      background = {
        # Snapshot the selected Nutstore artwork into the store so login does
        # not depend on the home directory or the sync client being available.
        path = "${../files/greetd/wallpaper.png}";
        fit = "Cover";
      };
      appearance.greeting_msg = "";
      widget.clock = {
        format = "%H:%M\n%A %d %B";
        resolution = "1s";
      };
    };
  };

  environment.etc."greetd/sway-config".source = pkgs.replaceVars ../files/greetd/sway-config {
    regreet = lib.getExe config.programs.regreet.package;
    swaymsg = "${pkgs.local.sway}/bin/swaymsg";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      # Use the same compositor and NVIDIA flag as the authenticated session.
      command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.local.sway}/bin/sway --unsupported-gpu --config /etc/greetd/sway-config";
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

  # Avoid installing NixOS's unrelated default font bundle alongside Sarasa.
  fonts.enableDefaultPackages = false;

  fonts.packages = with pkgs; [
    # Zhongdou contributes only CJK punctuation; Sarasa remains the text face.
    # Font preference is controlled by the fontconfig rules below.
    local.zhongdou-sans
    # This local package supplies only the Sarasa Fixed SC faces used here.
    local.sarasa-fixed-sc
    # Sarasa does not contain color emoji, so use Blobmoji as the fallback.
    local.blobmoji
    # Install only Nerd Font icon glyphs, not a patched text family. Neovim's
    # nvim-web-devicons plugin uses these private-use characters for file icons.
    nerd-fonts.symbols-only
  ];

  # Use Sarasa Fixed SC consistently whenever an application requests a
  # generic text font. Individual applications should only name a font when
  # they intentionally need a non-default size.
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Sarasa Fixed SC" ];
    serif = [ "Sarasa Fixed SC" ];
    monospace = [
      "Sarasa Fixed SC"
      # Use this only when Sarasa lacks a Neovim Devicon glyph.
      "Symbols Nerd Font Mono"
    ];
    # Blobmoji keeps the upstream Noto Color Emoji family name for application
    # compatibility, even though this local package supplies the glyphs.
    emoji = [ "Noto Color Emoji" ];
  };

  # Install this after fontconfig's generic emoji aliases. Color emoji fonts
  # contain ASCII digits for keycap sequences; placing Sarasa first prevents
  # browsers from using their oversized digit glyphs in ordinary prose while
  # retaining Noto Color Emoji for characters that Sarasa cannot render. Clear
  # the emoji alias's color and language preferences so fontconfig honors this
  # family order; glyph coverage still sends real emoji to the color font.
  fonts.fontconfig.confPackages = [
    (pkgs.writeTextFile {
      name = "fontconfig-text-before-emoji";
      destination = "/etc/fonts/conf.d/99-text-before-emoji.conf";
      text = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
        <fontconfig>
          <match target="pattern">
            <test name="family" compare="eq">
              <string>Noto Color Emoji</string>
            </test>
            <edit name="family" mode="assign" binding="strong">
              <string>Sarasa Fixed SC</string>
            </edit>
            <edit name="family" mode="append" binding="strong">
              <string>Noto Color Emoji</string>
            </edit>
            <edit name="color" mode="delete"/>
            <edit name="lang" mode="delete"/>
          </match>
        </fontconfig>
      '';
    })
  ];

  # Prefer Zhongdou punctuation only for sans-serif. Text Editor explicitly
  # requests this family for prose; terminals keep Sarasa as their monospace
  # primary font so a punctuation-only face cannot determine their cell size.
  fonts.fontconfig.localConf = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
    <fontconfig>
    <match target="pattern">
      <test name="family" compare="eq">
        <string>sans-serif</string>
      </test>
      <edit name="family" mode="prepend" binding="strong">
        <string>Zhongdou Sans</string>
      </edit>
    </match>
    </fontconfig>
  '';

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
