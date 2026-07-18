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
  programs.fzf = {
    enable = true; # Fuzzy search.
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  };
  programs.joshuto.enable = true; # Terminal file manager.
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
  programs.zsh = {
    enable = true;
    dotDir = home;
    oh-my-zsh = {
      enable = true;
      custom = "${./zsh-custom}";
      plugins = [
        "systemd"
        "github"
      ];
      theme = "bullet-train";
      extraConfig = ''
        BULLETTRAIN_RUBY_SHOW=false
        BULLETTRAIN_HG_SHOW=false
        BULLETTRAIN_EXEC_TIME_SHOW=true
        HYPHEN_INSENSITIVE="true"
        ENABLE_CORRECTION="true"
        COMPLETION_WAITING_DOTS="true"
      '';
    };
    envExtra = builtins.readFile ./zshenv.zsh;
    initContent = ''
      function alias_or_warning() {
        local a="$1"
        local b="$2"
        if alias "$a" >/dev/null 2>&1; then
          echo "Warning: Alias '$a' already exists." >&2
          local line_num file_name
          read line_num file_name <<< "$funcfiletrace"
          echo "Conflict position: '$file_name', '$line_num'"
        else
          alias "$a"="$b"
        fi
      }

      dir_list=("$XDG_CONFIG_HOME"/*)
      for ((i=0; i<''${#dir_list[@]}; i++)); do
        if [[ "''${dir_list[$i]}" == "$XDG_CONFIG_HOME/XDG" ]]; then
          tmp="''${dir_list[0]}"
          dir_list[0]="''${dir_list[$i]}"
          dir_list[$i]="$tmp"
          break
        fi
      done

      for dir in "''${dir_list[@]}"; do
        if [[ -f "''${dir}/dotenv" ]]; then
          source "''${dir}/dotenv"
        fi
      done

      eval "$(dircolors -b)"
      alias l="ls --color=auto"
      alias ll="ls -alFh --color=auto"

      alias_or_warning rm "rm -Iv --one-file-system"
      alias mkdir="nocorrect mkdir -pv"

      alias_or_warning stow "stow --no-folding --target=$HOME"
      alias_or_warning unstow "stow -D --target=$HOME"

      if [[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
        source /usr/share/doc/pkgfile/command-not-found.zsh
      fi

      alias_or_warning rg "rg -p"
      alias_or_warning "yt-dlp" "yt-dlp --proxy 127.0.0.1:2340 --write-subs --sub-langs zh-CN"
    '';
  };

  services.network-manager-applet.enable = true; # Tray for NetworkManager.
  services.udiskie = {
    enable = true;
    tray = "auto";
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
