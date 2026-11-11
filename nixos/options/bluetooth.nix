{ pkgs, ... }:

{
  # Include vendor firmware that Bluetooth and Wi-Fi adapters may require.
  hardware.enableAllFirmware = true;
  # The onboard RTL8821CE (13d3:3558) otherwise uses generic btusb setup,
  # which skips its installed firmware. Keep the stable kernel and backport
  # upstream's device entry; remove this once the selected kernel includes it.
  boot.kernelPatches = [
    {
      name = "btusb-rtl8821ce-13d3-3558";
      patch = pkgs.fetchurl {
        url = "https://github.com/torvalds/linux/commit/ac043b566ac3e7e27a58a6c9a3411e59466a0658.patch";
        hash = "sha256-COIQqIe42LT5MFZGC9EakF4+p9/UrTInpC39bqPzm6w=";
      };
    }
  ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # Improve support for Xbox-compatible controllers, including 8BitDo XInput.
  hardware.xpadneo.enable = true;
  services.blueman.enable = true;
}
