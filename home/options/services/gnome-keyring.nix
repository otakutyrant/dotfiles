{ lib, pkgs, ... }:

let
  # Standalone Home Manager has no NixOS capability wrapper. The user daemon
  # can serve encrypted credentials without that privileged wrapper.
  keyring = pkgs.gnome-keyring.override { useWrappedDaemon = false; };
in
{
  # Sway provides no credential store. Cindy's Electron safeStorage must have
  # an encrypted Secret Service before it can begin browser sign-in.
  services.gnome-keyring = {
    enable = true;
    package = keyring;
    components = [ "secrets" ];
  };

  # Publish activation files in the user's standard D-Bus search directory so
  # first-use password prompts also work without GNOME or a NixOS rebuild.
  xdg.dataFile."dbus-1/services/org.freedesktop.secrets.service".source =
    "${keyring}/share/dbus-1/services/org.freedesktop.secrets.service";
  xdg.dataFile."dbus-1/services/org.gnome.keyring.SystemPrompter.service".source =
    "${pkgs.gcr}/share/dbus-1/services/org.gnome.keyring.SystemPrompter.service";

  # Reload newly installed activation files before starting the keyring. NixOS
  # can activate Home Manager before login, when no user bus exists; the next
  # login discovers these files when it starts the bus.
  home.activation.reloadKeyringDbusServices =
    # no-bash-allow: Home Manager activation requires its shell DAG interface.
    lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "linkGeneration" ] ''
      keyringRuntimeDir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      if [[ -S "$keyringRuntimeDir/bus" ]]; then
        run ${pkgs.systemd}/bin/busctl --address="unix:path=$keyringRuntimeDir/bus" \
          call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig
      fi
      unset keyringRuntimeDir
    '';
}
