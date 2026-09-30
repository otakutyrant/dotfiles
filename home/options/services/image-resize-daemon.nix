{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  # Continuously upscale newly created images that are too small for normal
  # viewing while keeping the daemon tied to the user's default target.
  systemd.user.services.image-resize-daemon = {
    Unit = {
      Description = "Upscale small images under ${home}";
      After = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${home}/.local/bin/image_resize_daemon.nu --root ${home} --target-short-side 800 --interval 5";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
