{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  extraPackages = import ./extra-packages.nix { inherit lib pkgs; };
  home = config.home.homeDirectory;
  link = source: {
    inherit source;
    recursive = true;
  };
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  programs.nushell = {
    enable = true;
    plugins = [ pkgs.nushellPlugins.gstat ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    XDG_CONFIG_HOME = "${home}/.config";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  home.packages = extraPackages;

  home.file = {
    ".config/codex" = link ../Codex/.config/codex;
    ".config/git" = link ../Git/.config/git;
    ".config/gtk-3.0" = link ../X11/.config/gtk-3.0;
    ".config/i3" = link ../i3/.config/i3;
    ".config/i3status-rust" = link ../i3/.config/i3status-rust;
    ".config/joshuto" = link ../joshuto/.config/joshuto;
    ".config/kitty" = link ../Kitty/.config/kitty;
    ".config/mpv" = link ../mpv/.config/mpv;
    ".config/npm" = link ../npm/.config/npm;
    ".config/nushell" = link ../Nushell/.config/nushell;
    ".config/nvim" = link ../Neovim/.config/nvim;
    ".config/picom" = link ../XDG/.config/picom;
    ".config/ruff" = link ../Python/.config/ruff;
    ".config/tmux" = link ../Tmux/.config/tmux;
    ".gemini" = link ../Gemini/.gemini;
    ".local/bin" = link ../XDG/.local/bin;
    ".local/bin/forward" = {
      source = ../SSH/.local/bin/forward;
      executable = true;
    };
    ".local/bin/image_resize_daemon.py" = {
      source = ../Systemd/.local/bin/image_resize_daemon.py;
      executable = true;
    };
    ".local/bin/tmuxen.sh" = {
      source = ../Tmux/.local/bin/tmuxen.sh;
      executable = true;
    };
    ".ssh/config".source = ../SSH/.ssh/config;
    ".xinitrc".source = ../X11/.xinitrc;
    ".xprofile".source = ../X11/.xprofile;
    ".zsh-custom" = link ../Shell/.zsh-custom;
    ".zshenv".source = ../Shell/.zshenv;
    ".zshrc".source = ../Shell/.zshrc;
  }
  // lib.optionalAttrs (builtins.pathExists ../Shell/.oh-my-zsh/oh-my-zsh.sh) {
    ".oh-my-zsh" = link ../Shell/.oh-my-zsh;
  };

  systemd.user.services.image-resize-daemon = {
    Unit = {
      Description = "Upscale small images under ${home}";
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 ${home}/.local/bin/image_resize_daemon.py --root ${home} --target-short-side 800 --interval 5";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
