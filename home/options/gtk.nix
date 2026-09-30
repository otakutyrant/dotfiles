{
  config,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  gtk = {
    enable = true;
    # Provide a desktop-wide icon theme for applications launched by Sway.
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    gtk3 = {
      bookmarks = [
        "file://${home}/Pictures/Screenshots"
        "file://${home}/Nutstore%20Files/Nutstore"
        "file://${home}/Downloads"
        "file://${home}/Videos"
      ];
    };
  };
}
