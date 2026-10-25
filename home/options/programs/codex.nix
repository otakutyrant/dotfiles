{ pkgs, ... }:

let
  # Keep Codex's mutable config.toml under Codex's control while overriding the
  # new one-row-per-event scroll default for every CLI invocation.
  codexWithFasterScrolling = pkgs.symlinkJoin {
    name = "codex-with-faster-scrolling";
    paths = [ pkgs.unstable.codex ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/codex \
        --add-flags "--config tui.mouse_scroll_speed=3.0"
    '';
  };
in
{
  # Codex reads this context as its global behavior prompt. Command policy is
  # owned by the recursively imported codex-rules.nix sibling module.
  programs.codex = {
    enable = true;
    package = codexWithFasterScrolling;
    context = builtins.readFile ./codex-context.md;
  };

  # These packages are introduced specifically for Codex-driven development.
  # codex-rules.nix asserts that every package referenced by a generated rule
  # is declared in the final merged home.packages value.
  home.packages = [
    pkgs.shellcheck # Codex uses ShellCheck to lint maintained sh and Bash scripts.
    pkgs.shfmt # Codex uses shfmt to format maintained sh and Bash scripts.
    pkgs.actionlint # Codex uses actionlint to validate GitHub Actions workflows.
    pkgs.hadolint # Codex uses hadolint to lint Dockerfiles.
    pkgs.difftastic # Codex uses the `difft` binary for syntax-aware code review.
    pkgs.deadnix
    pkgs.local.nufmt
    pkgs.statix
    pkgs.desktop-file-utils
    pkgs.selene
    pkgs.nu-lint
    pkgs.strace # Codex uses strace to diagnose process and system-call behavior.
    pkgs.rsync # Codex uses rsync for efficient, metadata-aware file synchronization.
    pkgs.lsof # Codex uses lsof to identify processes that hold files or sockets.
    pkgs.iproute2 # Codex uses the iproute2 `ss` command to inspect network sockets.
  ];
}
