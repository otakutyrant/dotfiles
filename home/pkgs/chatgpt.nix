{
  callPackage,
  fetchFromGitHub,
  lib,
  codexHome ? null,
  userDataPath ? null,
}:

let
  # Reuse the pinned ChatGPT package expression and its launcher/source
  # metadata, while keeping the nixpkgs branch itself out of flake inputs.
  packageSource = fetchFromGitHub {
    owner = "Moraxyc";
    repo = "nixpkgs";
    rev = "294e967ba4b504cec68ab969c8850f01dd8433c2";
    hash = "sha256-jHCiuCFxgjf08Qv3pZEkr4AltnLA7HdNT1JaNy01pAc=";
  };
in
# The stable nixpkgs Codex package does not provide the matching
# `codex-code-mode-host` binary, so retain ChatGPT's bundled Codex resources.
(callPackage "${packageSource}/pkgs/by-name/ch/chatgpt/package.nix" {
  codex = null;
}).overrideAttrs
  (previous: {
    # GUI launches may lack the shell's CODEX_HOME. Pair it with an explicit
    # Electron profile path so ChatGPT preserves it during shell-env reloads.
    # Extend the package's existing wrapper instead of wrapping it a second time.
    postFixup =
      lib.optionalString (codexHome != null) ''
        gappsWrapperArgs+=(--set-default CODEX_HOME ${lib.escapeShellArg codexHome})
      ''
      + lib.optionalString (userDataPath != null) ''
        gappsWrapperArgs+=(--set-default CODEX_ELECTRON_USER_DATA_PATH ${lib.escapeShellArg userDataPath})
      ''
      + (previous.postFixup or "");
  })
