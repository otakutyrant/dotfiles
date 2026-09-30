{ ... }:

{
  # Start Walker's background application service with the graphical session
  # and retain the existing desktop-application provider settings.
  services.walker = {
    enable = true;
    systemd.enable = true;
    settings = {
      force_keyboard_focus = true;
      providers.default = [ "desktopapplications" ];
      providers.empty = [ "desktopapplications" ];
    };
  };
}
