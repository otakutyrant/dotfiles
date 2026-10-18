{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "blobmoji";
  version = "unstable-2025-09-29";

  # Blobmoji is not packaged by this nixpkgs revision. Pin the upstream commit
  # so a rebuild cannot silently change the emoji glyphs it installs.
  src = fetchFromGitHub {
    owner = "DavidBerdik";
    repo = "blobmoji-magisk";
    rev = "2c0082184ed2af9558ed2f5b83d84732441359fa";
    hash = "sha256-nBAZjXC5P1E/txgXdYcI5SGKoqJZTXEoVa5peNq3GCU=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 system/fonts/Blobmoji.ttf "$out/share/fonts/truetype/Blobmoji.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Noto Color Emoji with extended Blob emoji support";
    homepage = "https://github.com/DavidBerdik/blobmoji-magisk";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
