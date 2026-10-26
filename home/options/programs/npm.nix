{ config, lib, ... }:

{
  programs.npm = {
    enable = true;
    settings = {
      # Keep npm's otherwise ~/.npm cache under XDG_CACHE_HOME. Enabling
      # home.preferXdgDirectories moves the user npmrc to ~/.config/npm/npmrc.
      cache = "${config.xdg.cacheHome}/npm";
      # Use the USTC registry mirror for faster package metadata and downloads.
      registry = "https://npmreg.proxy.ustclug.org/";
    };
  };

  # Home Manager's XDG npm path currently retains the leading slash after
  # removing $HOME, producing a harmless but untidy double slash.
  home.sessionVariables.NPM_CONFIG_USERCONFIG = lib.mkForce "${config.xdg.configHome}/npm/npmrc";
}
