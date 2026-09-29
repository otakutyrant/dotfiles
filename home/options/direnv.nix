{ ... }:

{
  # direnv updates the current shell when entering a project directory.
  # nix-direnv adds the `use flake` command used by project .envrc files and
  # caches evaluated development environments for faster subsequent entry.
  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };
}
