{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  # Programs that only need Home Manager's default configuration belong here;
  # programs with additional settings live in focused sibling modules.
  programs.anki.enable = true;
  programs.btop.enable = true; # System monitor.
  programs.calibre.enable = true;
  programs.fd.enable = true; # Friendly alternative to find.
  programs.google-chrome.enable = true;
  programs.obs-studio.enable = true;
  programs.ripgrep.enable = true; # Grep alternative.
  programs.yt-dlp.enable = true; # YouTube downloader.

  # Anki creates this database before Home Manager activation on some systems.
  home.file."${home}/.local/share/Anki2/prefs21.db".force = true;
}
