{ ... }:

{
  # Both greetd and systemd-user read the PAM environment before starting their
  # independent process trees. Setting only environment.variables reaches the
  # profile-loaded Sway session but leaves launcher services without XIM.
  environment.sessionVariables = import ../../lib/session-environment.nix {
    cacheHome = "$HOME/.cache";
    stateHome = "$HOME/.local/state";
  };
}
