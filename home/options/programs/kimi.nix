{ config, pkgs, ... }:

{
  # Keep Kimi Code's mutable configuration and session state under its own
  # control in an XDG location while deploying the same global safety
  # instructions used by Codex.
  xdg.configFile = {
    "kimi-code/AGENTS.md".source = ../../files/AGENTS.md;
    # Give Bubblewrap an existing mount point that kimi-sandbox can replace
    # with a private tmpfs before Kimi creates per-instance server sockets.
    "kimi-code/server/.keep".text = "";
  };

  home.sessionVariables.KIMI_CODE_HOME = "${config.xdg.configHome}/kimi-code";
  home.packages = [ pkgs.local.kimi-code ];
}
