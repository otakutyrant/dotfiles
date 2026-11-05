{ config, pkgs, ... }:

{
  # Install personal executable scripts explicitly instead of discovering an
  # old Stow directory tree from the main Home Manager configuration.
  home.file.".local/bin" = {
    source = ../files/bin;
    recursive = true;
  };

  # These launchers need evaluated paths; keep their source templates separate
  # from scripts installed verbatim so no profile layout or XDG default leaks
  # into the raw source.
  home.file.".local/bin/codeql" = {
    source = pkgs.replaceVars ../files/libexec/codeql.nu {
      codeql = "${pkgs.codeql}/bin/codeql";
      cacheHome = config.xdg.cacheHome;
    };
    executable = true;
  };
  home.file.".local/bin/nvidia-settings" = {
    source = pkgs.replaceVars ../files/libexec/nvidia-settings.nu {
      configHome = config.xdg.configHome;
    };
    executable = true;
  };
}
