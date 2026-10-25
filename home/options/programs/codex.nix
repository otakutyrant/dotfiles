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
  # Codex reads this context as its global behavior prompt.
  programs.codex = {
    enable = true;
    package = codexWithFasterScrolling;
    context = builtins.readFile ./codex-context.md;
  };

  # These companion tools are introduced for Codex-driven development. Keep
  # them beside Codex instead of wrapping its package so they remain ordinary,
  # reusable commands in the Home Manager environment.
  home.packages = [
    pkgs.shellcheck # Codex uses ShellCheck to lint maintained sh and Bash scripts.
    pkgs.shfmt # Codex uses shfmt to format maintained sh and Bash scripts.
    pkgs.actionlint # Codex uses actionlint to validate GitHub Actions workflows.
    pkgs.hadolint # Codex uses hadolint to lint Dockerfiles.
    pkgs.difftastic # Codex uses the `difft` binary for syntax-aware code review.
    pkgs.strace # Codex uses strace to diagnose process and system-call behavior.
    pkgs.rsync # Codex uses rsync for efficient, metadata-aware file synchronization.
    pkgs.lsof # Codex uses lsof to identify processes that hold files or sockets.
    pkgs.iproute2 # Codex uses the iproute2 `ss` command to inspect network sockets.
  ];
}
