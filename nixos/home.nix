{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  homePackages = import ./home-packages.nix { inherit pkgs; };
  home = config.home.homeDirectory;
  # Recursively expose every file under a dotfile directory through Home
  # Manager, preserving each path relative to that directory.
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
  # Merge multiple stowed dotfile directories into one home.file attrset.
  stowAll = dirs: lib.foldl' (files: dir: files // stow dir) { } dirs;
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  programs.anki.enable = true;
  programs.btop.enable = true; # System monitor.
  programs.calibre.enable = true;
  programs.fd.enable = true; # Simple, fast and user-friendly alternative to find.
  programs.fzf = {
    enable = true; # Fuzzy search.
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  };
  programs.git = {
    enable = true;
    settings = {
      alias = {
        c = "commit";
        co = "checkout";
        d = "diff";
        s = "status";
        g = "log --name-only --graph --all --date=format-local:'%Y-%m-%d %H:%M:%S' --format='%C(auto)%h%d %cd %s'";
        l = "log --name-only";
      };
      credential.helper = "store";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      status.showStash = true;
      user = {
        name = "otakutyrant";
        email = "otakutyrant@gmail.com";
      };
    };
  };
  programs.google-chrome.enable = true;
  programs.joshuto.enable = true; # Terminal file manager.
  # Install local mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.callPackage ./pkgs/mpv.nix { };
  };
  programs.nushell = {
    enable = true;
    plugins = [ pkgs.nushellPlugins.gstat ];
  };
  programs.npm = {
    enable = true;
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.rofi.enable = true; # Application launcher.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        Hostname = "ssh.github.com";
        Port = 443;
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = false;
  };
  programs.zsh = {
    enable = true;
    # Store generated .zshrc/.zshenv files directly in $HOME for compatibility
    # with existing shell startup expectations.
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

  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    settings = {
      use-damage = true;
      # Let fullscreen windows bypass Picom for native refresh-rate presentation.
      unredir-if-possible = true;
      detect-client-opacity = true;
      detect-rounded-corners = true;
    };
  };
  services.udiskie = {
    enable = true;
    tray = "auto";
  };
  xdg.userDirs.enable = true;
  gtk = {
    enable = true;
    theme.name = "deepin";
    iconTheme.name = "Sea";
    font = {
      name = "Sarasa Gothic SC";
      size = 13;
    };
    cursorTheme = {
      name = "Adwaita";
      size = 0;
    };
    gtk3 = {
      bookmarks = [
        "file://${home}/Pictures/Screenshots"
        "file://${home}/Documents Documents"
        "file://${home}/Nutstore%20Files/Nutstore Nutstore"
        "file://${home}/tmp tmp"
        "file://${home}/Downloads"
        "file://${home}/Projects"
        "file://${home}/Videos"
      ];
      extraConfig = {
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = 0;
        gtk-menu-images = 0;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 1;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintmedium";
      };
    };
  };
  home.packages = homePackages;

  # Link the checked-in dotfile directories into the user's home directory.
  home.file = stowAll [
    ../Codex
    ../Gemini
    ../Kitty
    ../mpv
    ../Neovim
    ../Nushell
    ../Python
    ../Systemd
    ../Tmux
    ../X11
    ../XDG
    ../i3
    ../joshuto
  ];
}
