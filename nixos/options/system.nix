{ ... }:

{
  time.timeZone = "Asia/Shanghai";
  # Kill runaway processes before the kernel OOM killer freezes the desktop.
  services.earlyoom.enable = true;
}
