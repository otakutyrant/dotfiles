{ pkgs, ... }:

{
  programs.direnv = {
    # Install direnv, which selects a directory-specific environment from an
    # approved `.envrc` file.
    enable = true;
    package = pkgs.direnv;

    # Add a Nushell pre-prompt hook. After changing directories, the hook asks
    # direnv to load or unload environment variables for the new directory.
    enableNushellIntegration = true;

    # Add the `use flake` command used by this repository's `.envrc`. It loads
    # the flake's default development-shell environment into the current shell
    # and caches the Nix evaluation; it does not create the Nushell hook above.
    nix-direnv.enable = true;
  };
}
