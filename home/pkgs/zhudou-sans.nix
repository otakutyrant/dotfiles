{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhudou-sans";
  version = "unstable-2023-04-09";

  # Zhudou Sans is not packaged by this nixpkgs revision. Pin its final
  # upstream commit so its punctuation glyphs remain reproducible.
  src = fetchFromGitHub {
    owner = "Buernia";
    repo = "Zhudou-Sans";
    rev = "61f340baca1511a7e82f6220afc16e6c119d023f";
    hash = "sha256-0OA+37atwnCqTEBoWkSusrySYbJlc9ef+6iaW97zy3U=";
  };

  nativeBuildInputs = [ python3Packages.fonttools ];

  installPhase = ''
    runHook preInstall
    # Chromium uses Fontconfig for family selection but ignores its OpenType
    # feature settings. Bake Zhudou's centered-punctuation feature into the
    # font's default substitutions so Chrome and Fontconfig-aware apps agree.
    python ${./patch-zhudou-punctuation.py} fonts/variable/ZhudouSansVF.ttf ZhudouSansVF.ttf
    install -Dm444 ZhudouSansVF.ttf "$out/share/fonts/truetype/ZhudouSansVF.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Variable CJK punctuation font with centered punctuation by default";
    homepage = "https://github.com/Buernia/Zhudou-Sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
