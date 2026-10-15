{
  config,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  # Text Editor is used for prose, not code. Its system-font option requests
  # monospace, so select the generic sans-serif family explicitly instead.
  # Fontconfig then supplies Zhongdou punctuation and Sarasa text.
  dconf.settings."org/gnome/TextEditor" = {
    use-system-font = false;
    custom-font = "Sans 11";
  };

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
