{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhongdou-sans";
  version = "unstable-2026-10-14";

  # Pin the personal fork whose zh-CN locale uses zh-TW's centered `locl`
  # lookup, disables punctuation kern, defaults curly quotes to half-width, and
  # supplies a full-width, vertically centered U+22EF midline ellipsis, and
  # replaces the upstream one-em horizontal line gaps with 200-unit gaps.
  src = fetchFromGitHub {
    owner = "otakutyrant";
    repo = "Zhongdou-Sans";
    rev = "60e22f78c4a286ea76cdf7a9aa66ebbcbf355678";
    hash = "sha256-/VqjeZtJaHPWFtV6yljNELn96+iwN1rL32jHWuuQn7s=";
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
