{ hostname, ... }:

{
  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      # Clash Verge TUN mode handles DNS interception more reliably than the
      # router-provided resolver, so NetworkManager must not replace this list.
      dns = "none";
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
