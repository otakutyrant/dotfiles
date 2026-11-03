{ lib, pkgs, ... }:

{
  # Start Walker's background application service with the graphical session
  # and retain the existing desktop-application provider settings.
  services.walker = {
    enable = true;
    systemd.enable = true;
    settings = {
      force_keyboard_focus = true;
      providers.default = [ "desktopapplications" ];
      providers.empty = [ "desktopapplications" ];
    };
  };

  # Profile switches can leave Elephant's application index watching an older
  # generation. Refresh it after package and desktop-link updates, without
  # starting the backend when no graphical session has started it.
  home.activation.refreshElephant =
    lib.hm.dag.entryAfter
      [
        "installPackages"
        "updateUserDesktopDatabase"
        "reloadSystemd"
      ]
      ''
        run ${pkgs.systemd}/bin/systemctl --user try-restart elephant.service
      '';
}
