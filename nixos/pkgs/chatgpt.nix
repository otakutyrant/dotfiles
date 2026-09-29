{
  callPackage,
  fetchFromGitHub,
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
callPackage "${packageSource}/pkgs/by-name/ch/chatgpt/package.nix" {
  codex = null;
}
