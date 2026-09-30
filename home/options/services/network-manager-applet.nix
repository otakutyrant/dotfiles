{ ... }:

{
  # Ironbar reads StatusNotifier items, so start nm-applet in indicator mode
  # instead of its legacy XEmbed tray mode.
  xsession.preferStatusNotifierItems = true;
  services.network-manager-applet.enable = true;
}
