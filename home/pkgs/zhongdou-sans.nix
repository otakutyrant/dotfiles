{
  lib,
  python3Packages,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zhongdou-sans";
  version = "3.001";

  # Pin the formal upstream release so this profile uses the same source and
  # embedded font version as the downloadable Zhongdou Sans artifact.
  src = fetchFromGitHub {
    owner = "otakutyrant";
    repo = "Zhongdou-Sans";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0wk9OLPhlQbtFKPIWU3Pp/ursAyxvI7r5AzABG57LQs=";
  };

  nativeBuildInputs = [ python3Packages.fonttools ];

  installPhase = ''
    runHook preInstall
    # Upstream's deterministic FontTools build applies Zhongdou's focused
    # character set, OpenType behavior, metrics, and family metadata.
    python tools/build_font.py fonts/variable/ZhudouSansVF.ttf ZhongdouSansVF.ttf
    install -Dm444 ZhongdouSansVF.ttf "$out/share/fonts/truetype/ZhongdouSansVF.ttf"
    runHook postInstall
  '';

  meta = {
    description = "CJK punctuation font with centered Simplified Chinese punctuation";
    homepage = "https://github.com/otakutyrant/Zhongdou-Sans";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
