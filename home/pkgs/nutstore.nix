{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  python3,
  gobject-introspection,
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
  libGLU,
  fontconfig,
  freetype,
  glib,
  gdk-pixbuf,
  gtk3,
  webkitgtk_4_1,
  glib-networking,
  pango,
  harfbuzz,
  at-spi2-core,
  libnotify,
  libayatana-appindicator,
  alsa-lib,
  gst_all_1,
  xdg-utils,
  procps,
  nautilus,
}:

let
  pythonEnv = python3.withPackages (pythonPackages: [
    pythonPackages.pygobject3
  ]);
  typelibPath = lib.makeSearchPath "lib/girepository-1.0" (
    map lib.getLib [
      glib
      gdk-pixbuf
      gtk3
      webkitgtk_4_1
      pango
      harfbuzz
      at-spi2-core
      libnotify
      libayatana-appindicator
      gobject-introspection
    ]
  );
  gstPluginPath = lib.makeSearchPath "lib/gstreamer-1.0" [
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];
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
    unzip
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
    libGLU
    fontconfig
    freetype
    glib
    gdk-pixbuf
    gtk3
    webkitgtk_4_1
    glib-networking
    pango
    harfbuzz
    at-spi2-core
    libnotify
    libayatana-appindicator
    alsa-lib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/nutstore $out/share/applications $out/share/pixmaps
    cp -r . $out/share/nutstore/
    unzip -j $out/share/nutstore/lib/nutstore_client-${version}.jar '*.so' -d $out/share/nutstore/lib/native

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
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          webkitgtk_4_1
        ]
      }" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${gstPluginPath}" \
      --prefix GI_TYPELIB_PATH : "${typelibPath}"

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
