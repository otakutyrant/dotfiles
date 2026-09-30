{ ... }:

{
  # Services that only need Home Manager's default configuration belong here;
  # services with additional settings live in focused sibling modules.
  services.polkit-gnome.enable = true;
}
