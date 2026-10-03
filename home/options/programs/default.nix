{
  config,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  withFcitxQt = pkgs.callPackage ../../../lib/wrap-with-fcitx-qt.nix { };
  # Home Manager calls Anki's withAddons function after reading this package.
  # Wrap that final package so the add-on and Fcitx wrappers are both retained.
  ankiWithFcitx = pkgs.anki.overrideAttrs (oldAttrs: {
    passthru = (oldAttrs.passthru or { }) // {
      withAddons =
        addons:
        withFcitxQt {
          package = pkgs.anki.withAddons addons;
          executables = [
            "anki"
            "ankiw"
          ];
        };
    };
  });
in
{
  # Programs that only need Home Manager's default configuration belong here;
  # programs with additional settings live in focused sibling modules.
  programs.anki = {
    enable = true;
    package = ankiWithFcitx;
  };
  programs.btop.enable = true; # System monitor.
  programs.calibre = {
    enable = true;
    package = withFcitxQt {
      package = pkgs.calibre;
      executables = [
        "calibre"
        "ebook-edit"
        "ebook-viewer"
        "lrfviewer"
      ];
    };
  };
  programs.fd.enable = true; # Friendly alternative to find.
  programs.google-chrome.enable = true;
  programs.obs-studio = {
    enable = true;
    package = withFcitxQt {
      package = pkgs.obs-studio;
      executables = [ "obs" ];
    };
  };
  programs.ripgrep.enable = true; # Grep alternative.
  programs.yt-dlp.enable = true; # YouTube downloader.

  # Anki creates this database before Home Manager activation on some systems.
  home.file."${home}/.local/share/Anki2/prefs21.db".force = true;
}
