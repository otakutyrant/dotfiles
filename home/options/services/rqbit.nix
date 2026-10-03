{
  config,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  # Keep rqbit's HTTP API and torrent session alive for the whole graphical
  # login. The download directory is also rqbit's default output directory.
  systemd.user.services.rqbit = {
    Unit = {
      Description = "rqbit BitTorrent server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${home}/Downloads";
      # Clash's fake-IP DNS maps the default DHT bootstrap hostnames into
      # 198.18.0.0/16, where rqbit cannot complete its UDP bootstrap. Use the
      # bootstrap servers' real IPv4 addresses. Bind rqbit to the physical
      # Wi-Fi interface so DHT UDP bypasses Clash's unreliable gVisor TUN path.
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.unstable.rqbit}/bin/rqbit"
        "--bind-device wlp7s0"
        "--dht-bootstrap-addrs 185.157.221.247:25401,87.98.162.88:6881,212.129.33.59:6881"
        "server start ${home}/Downloads"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
