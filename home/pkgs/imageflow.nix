{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  stdenv,
  openssl,
  zlib,
  libpng,
  libjpeg,
  libwebp,
  lcms2,
  libtiff,
  libavif,
  curl,
}:

# Use Imageflow's upstream Linux x86_64 release bundle. It contains the
# `imageflow_tool` CLI and any companion shared library files from that build.
stdenvNoCC.mkDerivation rec {
  pname = "imageflow";
  version = "2.3.1-rc01";

  src = fetchurl {
    url = "https://github.com/imazen/imageflow/releases/download/v${version}/imageflow-v${version}-0635e386-linux-x64.tar.gz";
    hash = "sha256-iCkQxslgLkI2Xc8cLEEstdDO1HA7+GEhfl7yQqYVu7M=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    openssl
    zlib
    libpng
    libjpeg
    libwebp
    lcms2
    libtiff
    libavif
    curl
  ];

  dontBuild = true;

  # The release archive has files at its root and a `headers/` directory;
  # select the archive root instead of Nix's default first directory.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    tool=$(find . -type f -name imageflow_tool -print -quit)
    test -n "$tool"
    install -Dm755 "$tool" $out/bin/imageflow_tool

    while IFS= read -r library; do
      install -Dm755 "$library" "$out/lib/$(basename "$library")"
    done < <(find . -type f -name 'libimageflow.so*' -print)

    runHook postInstall
  '';

  meta = {
    description = "High-performance image manipulation command-line tool";
    homepage = "https://github.com/imazen/imageflow";
    license = lib.licenses.agpl3Plus;
    mainProgram = "imageflow_tool";
    platforms = [ "x86_64-linux" ];
  };
}
