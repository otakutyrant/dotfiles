{ ... }:

{
  # Include vendor firmware that Bluetooth and Wi-Fi adapters may require.
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # Improve support for Xbox-compatible controllers, including 8BitDo XInput.
  hardware.xpadneo.enable = true;
  services.blueman.enable = true;
}
