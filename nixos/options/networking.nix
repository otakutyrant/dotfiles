{ hostname, ... }:

{
  # Pin the internal Wi-Fi adapter to the name used by interface-scoped rules
  # and services, even if systemd's default naming policy changes later.
  systemd.network.links."10-internal-wifi" = {
    matchConfig.Path = "pci-0000:07:00.0";
    linkConfig.Name = "wlp7s0";
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      # Clash Verge TUN mode handles DNS interception more reliably than the
      # router-provided resolver, so NetworkManager must not replace this list.
      dns = "none";
    };
    # LocalSend only needs its discovery and transfer port on the Wi-Fi LAN;
    # keep it closed on Docker, Clash's TUN interface, and any future links.
    firewall.interfaces.wlp7s0 = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
    nameservers = [
      "223.5.5.5" # AliDNS.
      "223.6.6.6" # AliDNS fallback.
      "119.29.29.29" # DNSPod.
      "180.76.76.76" # Baidu DNS.
      "8.8.8.8" # Google fallback; it may require Clash in mainland China.
      "1.1.1.1" # Cloudflare fallback; it may also require Clash.
    ];
  };
}
