{ ... }:

{
  # Source only Joshuto's helper scripts; Home Manager continues generating
  # joshuto.toml and mimetype.toml from the structured settings below.
  xdg.configFile."joshuto" = {
    source = ../../files/config/joshuto;
    recursive = true;
  };

  programs.joshuto = {
    enable = true; # Terminal file manager.
    # Keep Joshuto's TOML settings in Home Manager; its preview scripts remain
    # linked from the joshuto directory and are referenced here by path.
    settings = {
      xdg_open = true;
      display.line_number_style = "relative";
      preview = {
        preview_script = "~/.config/joshuto/preview_file.nu";
        preview_shown_hook_script = "~/.config/joshuto/on_preview_shown.nu";
        preview_removed_hook_script = "~/.config/joshuto/on_preview_removed.nu";
      };
    };
    mimetype = {
      # Joshuto stores opener classes and MIME mappings in mimetype.toml.
      class.text_default = [ { command = "nvim"; } ];
      mimetype.text."inherit" = "text_default";
    };
  };
}
