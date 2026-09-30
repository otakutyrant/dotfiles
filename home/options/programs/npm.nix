{ ... }:

{
  programs.npm = {
    enable = true;
    # Use the USTC registry mirror for faster package metadata and downloads.
    settings.registry = "https://npmreg.proxy.ustclug.org/";
  };
}
