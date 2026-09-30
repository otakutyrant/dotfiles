{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  # PipeWire uses rtkit for low-latency real-time scheduling.
  security.rtkit.enable = true;
}
