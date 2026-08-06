{
  programs.kitty = {
    enable = true;
    # Home Manager writes this block to kitty.conf and installs kitty, so the
    # terminal config can live beside the other program modules.
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10.0;
    };
    keybindings = {
      "alt+v" = "launch --location=vsplit --cwd=current";
      "alt+s" = "launch --location=hsplit --cwd=current";
      "alt+h" = "neighboring_window left";
      "alt+j" = "neighboring_window down";
      "alt+k" = "neighboring_window up";
      "alt+l" = "neighboring_window right";
      "alt+q" = "close_window";
      "alt+minus" = "goto_layout vertical";
      # `alt+bar` does not work here, so keep the literal bar mapping that the
      # previous kitty.conf used.
      "alt+|" = "goto_layout horizontal";
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+7" = "goto_tab 7";
      "alt+8" = "goto_tab 8";
      "alt+9" = "goto_tab 9";
      "alt+0" = "goto_tab 10";
      "alt+n" = "new_tab";
    };
    settings = {
      enabled_layouts = "splits, horizontal, vertical, grid";
      scrollback_pager = "page";
      tab_bar_style = "powerline";
      tab_title_template = "{index} : {title}";
      background_opacity = "0.8";
      allow_remote_control = "yes";
      # Keep the cursor blinking forever instead of stopping after the default
      # 15 seconds of inactivity, so the cursor stays obvious at a glance.
      cursor_stop_blinking_after = "0";
      # Use a bright cyan cursor so it stands out clearly against dark backgrounds.
      cursor = "#00ffff";
      cursor_text_color = "background";
      # Blink faster than the default 0.5s so the cursor draws more attention.
      cursor_blink_interval = "0.3";
    };
  };
}
