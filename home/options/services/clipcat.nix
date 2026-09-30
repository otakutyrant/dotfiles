{ ... }:

{
  # Use Home Manager's service modules while keeping the hand-written Clipcat
  # files from the XDG option module authoritative.
  services.clipcat = {
    enable = true;
    daemonSettings = { };
    ctlSettings = { };
    menuSettings = { };
  };
}
