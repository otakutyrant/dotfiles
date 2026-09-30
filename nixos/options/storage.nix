{ username, ... }:

{
  # Mount the Windows-compatible shared partition without blocking boot when
  # the device is unavailable.
  fileSystems."/run/media/${username}/Shared" = {
    device = "/dev/disk/by-uuid/6FB7-A952";
    fsType = "exfat";
    options = [
      "nofail"
      "rw"
      "uid=1000"
      "gid=100"
      "umask=0002"
      "x-gvfs-show"
    ];
  };

  # Use compressed RAM first, then a disk-backed fallback for large builds.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  swapDevices = [
    {
      device = "/swapfile";
      # NixOS expresses swap-file size in MiB, so this creates 32 GiB.
      size = 32768;
    }
  ];
}
