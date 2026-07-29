{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeDesktopItem,
  makeWrapper,
  gtk3,
  glib,
  cairo,
  pango,
  atk,
  gdk-pixbuf,
  libnotify,
  ayatana-ido,
  libayatana-appindicator,
  libdbusmenu-gtk3,
  libX11,
  libXext,
  libXi,
  libXfixes,
  libXcursor,
  libXdamage,
  libXcomposite,
  libXrandr,
  libXinerama,
  libXrender,
  libxcb,
  libxkbcommon,
  libepoxy,
  at-spi2-core,
  fontconfig,
  freetype,
  harfbuzz,
  fribidi,
  libthai,
  graphite2,
  libpng,
  pixman,
  lcms2,
  libglycin,
  json-glib,
  libxml2,
  sqlite,
  tinysparql,
  libcloudproviders,
  icu,
  zlib,
  bzip2,
  brotli,
  pcre2,
  libffi,
  dbus,
  libseccomp,
  util-linux,
  systemd,
  dmidecode,
}:

stdenv.mkDerivation rec {
  pname = "nfcloud";
  version = "1.4.15";

  src = fetchurl {
    url = "https://backendoss.trafficmanager.net/api/v1/app/get/nfcloud/linux";
    name = "nfcloud-linux-${version}.tar.gz";
    hash = "sha256-iK/BXaT6vGC2dY3704oJKjHAVKBp+kSb8Wn5ZomPVL0=";
  };

  # Upstream archive lacks a top-level wrapper directory.
  # Set sourceRoot to current directory to prevent Nix from searching for a non-existent subdirectory.
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # wayland is intentionally excluded to force Flutter to use the X11 backend.
  # The upstream binary is built against GTK3 but runs via Flutter's Linux embedder,
  # which probes for wayland-egl and fails if WAYLAND_DISPLAY is unavailable.
  buildInputs = [
    gtk3
    glib
    cairo
    pango
    atk
    gdk-pixbuf
    libnotify
    ayatana-ido
    libayatana-appindicator
    libdbusmenu-gtk3
    libX11
    libXext
    libXi
    libXfixes
    libXcursor
    libXdamage
    libXcomposite
    libXrandr
    libXinerama
    libXrender
    libxcb
    libxkbcommon
    libepoxy
    at-spi2-core
    fontconfig
    freetype
    harfbuzz
    fribidi
    libthai
    graphite2
    libpng
    pixman
    lcms2
    libglycin
    json-glib
    libxml2
    sqlite
    tinysparql
    libcloudproviders
    icu
    zlib
    bzip2
    brotli
    pcre2
    libffi
    dbus
    libseccomp
    util-linux
    systemd
    stdenv.cc.cc.lib
  ];

  desktopItem = makeDesktopItem {
    # Generate the .desktop file from structured Nix data instead of patching
    # upstream desktop-file text by hand.
    name = "nfcloud";
    exec = "nfcloud";
    icon = "nfcloud";
    comment = "NFCLOUD Client";
    desktopName = "NFCLOUD";
    categories = [ "Network" ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,libexec/nfcloud,share/applications,share/pixmaps}
    cp -r bundle/* $out/libexec/nfcloud/

    cp ${desktopItem}/share/applications/* $out/share/applications/
    cp $out/libexec/nfcloud/data/flutter_assets/assets/icons/app_icon.png $out/share/pixmaps/nfcloud.png

    # Keep the upstream Flutter bundle under libexec and expose only the main
    # launcher on PATH. autoPatchelfHook still follows this symlink and patches
    # the real ELF binary.
    ln -s $out/libexec/nfcloud/relayway $out/bin/nfcloud

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/nfcloud \
        --set GDK_BACKEND x11 \
        --unset WAYLAND_DISPLAY \
        --prefix PATH : ${lib.makeBinPath [ dmidecode ]}
  '';

  meta = with lib; {
    description = "NFCLOUD Linux desktop client";
    homepage = "https://backendoss.trafficmanager.net";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "nfcloud";
  };
}
