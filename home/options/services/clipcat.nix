{ pkgs, ... }:

{
  # Use Home Manager's service modules while keeping the hand-written Clipcat
  # files from the XDG option module authoritative.
  services.clipcat = {
    enable = true;
    # Use the build whose embedded wl-clipboard-rs tolerates abandoned reads.
    package = pkgs.local.clipcat;
    daemonSettings = { };
    ctlSettings = { };
    menuSettings = { };
  };
}
