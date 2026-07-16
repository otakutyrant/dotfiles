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
  imageResizePython = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.pillow
  ]);
  stow =
    dir:
    let
      collect =
        prefix: path:
        lib.concatMapAttrs (
          name: type:
          let
            relativePath = if prefix == "" then name else "${prefix}/${name}";
            sourcePath = path + "/${name}";
          in
          if type == "directory" then
            collect relativePath sourcePath
          else
            {
              ${relativePath}.source = sourcePath;
            }
        ) (builtins.readDir path);
    in
    collect "" dir;
  stowAll = dirs: lib.foldl' (files: dir: files // stow dir) { } dirs;
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = false;
  programs.btop.enable = true; # System monitor.
  programs.fd.enable = true; # Simple, fast and user-friendly alternative to find.
  programs.fzf.enable = true; # Fuzzy search.
  programs.nushell = {
    enable = true;
    plugins = [ pkgs.nushellPlugins.gstat ];
  };
  programs.ripgrep.enable = true; # Grep alternative.
  programs.rofi.enable = true; # Application launcher.
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = false;
  };

  services.network-manager-applet.enable = true; # Tray for NetworkManager.
  services.udiskie = {
    enable = true;
    tray = "auto";
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

  home.file =
    stowAll [
      ../Codex
      ../Gemini
      ../Git
      ../Kitty
      ../mpv
      ../Neovim
      ../npm
      ../Nushell
      ../Python
      ../Shell
      ../SSH
      ../Tmux
      ../X11
      ../XDG
      ../i3
      ../joshuto
    ]
    // {
      ".local/bin/image_resize_daemon.py" = {
        source = ../Systemd/.local/bin/image_resize_daemon.py;
        executable = true;
      };
    };

  systemd.user.services.image-resize-daemon = {
    Unit = {
      Description = "Upscale small images under ${home}";
      After = [ "default.target" ];
      StartLimitBurst = 3;
      StartLimitIntervalSec = 60;
    };
    Service = {
      Type = "simple";
      ExecStart = "${imageResizePython}/bin/python3 ${home}/.local/bin/image_resize_daemon.py --root ${home} --target-short-side 800 --interval 5";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
