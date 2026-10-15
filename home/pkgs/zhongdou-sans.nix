{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhongdou-sans";
  version = "unstable-2026-10-15";

  # Pin the personal fork whose zh-CN locale uses zh-TW's centered `locl`
  # lookup, keeps punctuation at full width, centers brackets at every weight,
  # defaults curly quotes to half-width, supplies a centered U+22EF ellipsis,
  # and aligns fallback baselines with Sarasa Fixed SC in Pango/GTK.
  src = fetchFromGitHub {
    owner = "otakutyrant";
    repo = "Zhongdou-Sans";
    rev = "cc26db0c9cb4a69abd8b0f953010033f9bd21417";
    hash = "sha256-sjl/SJhc9neFBwkgMNmW3+HRzxOinMvZvoRNxtIDjEY=";
  };

  nativeBuildInputs = [ python3Packages.fonttools ];

  installPhase = ''
    runHook preInstall
    # Upstream provides Glyphs source but no automated compiler, so the fork
    # reproducibly applies its locale policy to the shipped variable font.
    python tools/build_font.py fonts/variable/ZhudouSansVF.ttf ZhongdouSansVF.ttf
    install -Dm444 ZhongdouSansVF.ttf "$out/share/fonts/truetype/ZhongdouSansVF.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Variable CJK punctuation font with centered zh-CN and half-width quotes";
    homepage = "https://github.com/otakutyrant/Zhongdou-Sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
