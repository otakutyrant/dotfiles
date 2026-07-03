{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  python3,
  zlib,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  libXrandr,
  libXcursor,
  libXdamage,
  libXfixes,
  libXcomposite,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libnotify,
  libayatana-appindicator,
  alsa-lib,
  xdg-utils,
  procps,
  nautilus,
}:

let
  pythonEnv = python3.withPackages (pythonPackages: [
    pythonPackages.pygobject3
  ]);
in
stdenv.mkDerivation rec {
  pname = "nutstore";
  version = "6.4.3";

  src = fetchurl {
    url = "https://pkg-cdn.jianguoyun.com/static/exe/installer/nutstore_linux_dist_x86_64.tar.gz";
    hash = "sha256-sG3NrWTP1joKztkNddzz8x1xPVg9qZIKlKI7tIw/2xI=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    zlib
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libXrandr
    libXcursor
    libXdamage
    libXfixes
    libXcomposite
    fontconfig
    freetype
    glib
    gtk3
    libnotify
    libayatana-appindicator
    alsa-lib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/nutstore $out/share/applications $out/share/pixmaps
    cp -r . $out/share/nutstore/

    cp $out/share/nutstore/app-icon/nutstore.png $out/share/pixmaps/nutstore.png
    substitute $out/share/nutstore/gnome-config/menu/nutstore-menu.desktop \
      $out/share/applications/nutstore.desktop \
      --replace-fail 'Exec=sh -c "exec ~/.nutstore/dist/bin/nutstore-pydaemon.py"' 'Exec=nutstore'

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/nutstore \
      --add-flags "$out/share/nutstore/bin/nutstore-pydaemon.py" \
      --prefix PATH : ${
        lib.makeBinPath [
          xdg-utils
          procps
          nautilus
        ]
      } \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Nutstore Linux desktop sync client";
    homepage = "https://www.jianguoyun.com/s/downloads/linux";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nutstore";
  };
}
