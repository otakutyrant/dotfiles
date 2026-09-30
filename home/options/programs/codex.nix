{ pkgs, ... }:

{
  # Codex reads this context as its global behavior prompt.
  programs.codex = {
    enable = true;
    package = pkgs.unstable.codex;
    context = builtins.readFile ./codex-context.md;
  };
}
