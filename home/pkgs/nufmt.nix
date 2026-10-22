{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nufmt";
  version = "0.1.6";

  # nixpkgs still ships the older formatter that corrupted valid Nushell in
  # this repository. Use the upstream release until nixpkgs catches up.
  src = fetchurl {
    url = "https://github.com/nushell/nufmt/releases/download/v${finalAttrs.version}/nufmt-x86_64-unknown-linux-gnu.tar.xz";
    hash = "sha256-xXIXEwU3D3ZpF6oDeVAy1SICzRHryC4KMyS74jiS9k4=";
  };

  sourceRoot = "nufmt-x86_64-unknown-linux-gnu";

  installPhase = ''
    runHook preInstall
    install -Dm755 nufmt "$out/bin/nufmt"
    runHook postInstall
  '';

  meta = {
    description = "Nushell code formatter";
    homepage = "https://github.com/nushell/nufmt";
    license = lib.licenses.mit;
    mainProgram = "nufmt";
    platforms = [ "x86_64-linux" ];
  };
})
