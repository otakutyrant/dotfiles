{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

let
  homePackages = import ./home-packages.nix { inherit inputs pkgs; };
  home = config.home.homeDirectory;
  # Recursively expose every file under a dotfile directory through Home
  # Manager, preserving each path relative to that directory.
  linkDotfileDir =
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
  # Merge multiple dotfile directories into one Home Manager file attrset.
  linkDotfileDirs = dirs: lib.foldl' (files: dir: files // linkDotfileDir dir) { } dirs;
in
{
  # Keep large Home Manager option groups in focused sibling modules so this
  # file stays readable while still evaluating as one merged user profile.
  imports = [
    ./options/codex.nix
    ./options/env.nix
    ./options/git.nix
    ./options/kitty.nix
    ./options/nushell.nix
    ./options/picom.nix
    ./options/ssh.nix
    ./options/starship.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  # Session PATH additions. These used to be added by Nushell startup files, but
  # they are useful to programs launched outside Nushell too.
  home.sessionPath = [
    "${home}/.local/bin"
    "${home}/.nix-profile/bin"
    "${home}/.local/share/cargo/bin"
  ];

  programs.anki.enable = true;
  programs.btop.enable = true; # System monitor.
  programs.calibre.enable = true;
  programs.fd.enable = true; # Simple, fast and user-friendly alternative to find.
  programs.fzf = {
    enable = true; # Fuzzy search.
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
  };
  programs.google-chrome.enable = true;
  programs.joshuto.enable = true; # Terminal file manager.
  # Install local mpv package with Unicode-aware subtitle line wrapping through
  # Home Manager's mpv module.
  programs.mpv = {
    enable = true;
    package = pkgs.callPackage ./pkgs/mpv.nix { };
  };
  programs.npm = {
    enable = true;
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.rofi.enable = true; # Application launcher.
  programs.yt-dlp.enable = true; # YouTube downloader.
  programs.zoxide = {
    enable = true; # Jump tool.
    enableNushellIntegration = true;
  };

  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;
  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  # Diodon ignores copied images by default. Enable image history so screenshot
  # PNG clipboard entries can appear in its menu.
  dconf.settings."net/launchpad/diodon/clipboard".add-images = true;
  xdg.userDirs.enable = true;
  xdg.configFile."user-dirs.dirs".force = true;
  # Set an explicit Xcursor theme instead of relying on toolkit fallbacks.
  # Lightweight i3 sessions do not get a desktop environment to choose one for
  # them, and GLFW/Kitty expects the active theme to provide standard resize
  # cursors such as diagonal sizing aliases.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  gtk = {
    enable = true;
    gtk3 = {
      bookmarks = [
        "file://${home}/Pictures/Screenshots"
        "file://${home}/Nutstore%20Files/Nutstore"
        "file://${home}/Downloads"
        "file://${home}/Videos"
      ];
    };
  };
  home.packages = homePackages;

  # User services
  systemd.user.services.image-resize-daemon = {
    Unit = {
      Description = "Upscale small images under /home/otakutyrant";
      After = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${home}/.local/bin/image_resize_daemon.nu --root ${home} --target-short-side 800 --interval 5";
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  # Link the checked-in dotfile directories into the user's home directory.
  home.file =
    (linkDotfileDirs [
      ../mpv
      ../Neovim
      ../Tmux
      ../XDG
      ../i3
      ../joshuto
    ])
    // {
      "${home}/.local/share/Anki2/prefs21.db".force = true;
    };
}
