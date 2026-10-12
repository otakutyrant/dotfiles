{
  lib,
  stdenvNoCC,
  fetchurl,
  p7zip,
}:

# I do not intend to publish this profile-specific package to nixpkgs.
# Nixpkgs' sarasa-gothic package installs every family, language, and weight.
# This package keeps only the regular hinted Simplified-Chinese Sarasa Fixed
# face used by this profile, avoiding separate weight/style family entries in
# font pickers and making the installed font closure substantially smaller.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sarasa-fixed-sc";
  version = "1.0.37";

  src = fetchurl {
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${finalAttrs.version}/SarasaFixedSC-TTF-${finalAttrs.version}.7z";
    hash = "sha256-lg5ZVZGJ5DfvFahpr/bkoFlrNcm+oYk1I/oTcK97SkY=";
  };

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    runHook preUnpack
    7z x $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 SarasaFixedSC-Regular.ttf "$out/share/fonts/truetype/SarasaFixedSC-Regular.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Sarasa Fixed Simplified Chinese font family";
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
