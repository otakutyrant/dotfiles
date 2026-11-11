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
        # NixOS also activates Home Manager before login, when no user bus exists.
        # Match reloadSystemd's runtime-directory fallback and skip that boot phase;
        # the graphical session starts Elephant later with its desktop environment.
        elephantRuntimeDir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        elephantSystemdStatus=$(env XDG_RUNTIME_DIR="$elephantRuntimeDir" \
          ${pkgs.systemd}/bin/systemctl --user is-system-running 2>/dev/null || true)
        if [[ "$elephantSystemdStatus" == running || "$elephantSystemdStatus" == degraded ]]; then
          run env XDG_RUNTIME_DIR="$elephantRuntimeDir" \
            ${pkgs.systemd}/bin/systemctl --user try-restart elephant.service
        fi
        unset elephantRuntimeDir elephantSystemdStatus
      '';
}
