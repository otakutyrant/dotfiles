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
          # Keep the following Nix syntax line documented.
          if [[ "''${dir_list[$i]}" == "$XDG_CONFIG_HOME/XDG" ]]; then
            tmp="''${dir_list[0]}"
            # Keep the following Nix syntax line documented.
            dir_list[0]="''${dir_list[$i]}"
            dir_list[$i]="$tmp"
            break
          fi
        done

        for dir in "''${dir_list[@]}"; do
          # Keep the following Nix syntax line documented.
          if [[ -f "''${dir}/dotenv" ]]; then
            source "''${dir}/dotenv"
          # Provide a function or module argument named `fi`.
          fi
        # Provide a function or module argument named `done`.
        done

        # Keep the following Nix syntax line documented.
        eval "$(dircolors -b)"
        # Keep the following Nix syntax line documented.
        alias l="ls --color=auto"
        # Keep the following Nix syntax line documented.
        alias ll="ls -alFh --color=auto"

        # Keep the following Nix syntax line documented.
        alias_or_warning rm "rm -Iv --one-file-system"
        # Keep the following Nix syntax line documented.
        alias mkdir="nocorrect mkdir -pv"

        # Keep the following Nix syntax line documented.
        alias_or_warning stow "stow --no-folding --target=$HOME"
        # Keep the following Nix syntax line documented.
        alias_or_warning unstow "stow -D --target=$HOME"

        # Keep the following Nix syntax line documented.
        if [[ -r /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
          # Keep the following Nix syntax line documented.
          source /usr/share/doc/pkgfile/command-not-found.zsh
        # Provide a function or module argument named `fi`.
        fi

        # Keep the following Nix syntax line documented.
        alias_or_warning rg "rg -p"
        # Keep the following Nix syntax line documented.
        alias_or_warning "yt-dlp" "yt-dlp --proxy 127.0.0.1:2340 --write-subs --sub-langs zh-CN"
      # Keep the following Nix syntax line documented.
    '';
  };

  services.network-manager-applet.enable = true;
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  home.packages = homePackages;

  # Link the checked-in dotfile directories into the user's home directory.
  home.file = stowAll [
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
    ../Systemd
    ../Tmux
    ../X11
    ../XDG
    ../i3
    ../joshuto
  ];
}
