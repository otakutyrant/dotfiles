{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhongdou-sans";
  version = "unstable-2026-10-16";

  # Pin the personal fork whose zh-CN locale uses zh-TW's centered `locl`
  # lookup, keeps punctuation at full width, centers brackets at every weight,
  # defaults curly quotes to half-width, supplies a centered U+22EF ellipsis,
  # removes unrelated alphanumerics and symbol collections, and aligns fallback
  # baselines with Sarasa Fixed SC in Pango/GTK.
  src = fetchFromGitHub {
    owner = "otakutyrant";
    repo = "Zhongdou-Sans";
    rev = "6ece193a663214b8efc503702382cab5cecdbc5a";
    hash = "sha256-c9bT5NC/XBHFlSx+mygmJYb6X8sELFgZdVsqpy4uDZM=";
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
