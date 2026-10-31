{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  json_c,
  libdrm,
  libgbm,
  libGL,
  libsecret,
  libpng,
  libpulseaudio,
  libxkbcommon,
  libX11,
  libxcb,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
}:

# Upstream has no flake. Keep the release's Electron runtime paired with its
# native Node modules rather than substituting a different Electron ABI.
stdenv.mkDerivation rec {
  pname = "cindy";
  version = "0.1.121";

  # This host uses the China edition; the global edition has separate accounts
  # and a separate Electron userData directory.
  src = fetchurl {
    url = "https://github.com/makecindy/cindy/releases/download/v${version}/cindy-${version}-linux-x64-cn.deb";
    hash = "sha256-lB5VvCOByHRgxcYIekjlX01QNzWYKnNjvUt8gIwtKxQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    json_c
    libgbm
    libpng
    libxkbcommon
    libX11
    libxcb
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    wayland
  ];

  # Electron loads these libraries at runtime rather than through ELF NEEDED.
  runtimeDependencies = map lib.getLib [
    libdrm
    libGL
    libsecret
    libpulseaudio
    vulkan-loader
  ];

  unpackPhase = ''
    runHook preUnpack
    # Nix cannot install the Debian archive's setuid chrome-sandbox helper;
    # Chromium uses the unprivileged user-namespace sandbox on this host.
    dpkg-deb --fsys-tarfile "$src" | tar --no-same-owner --no-same-permissions -xf -
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib" "$out/bin" "$out/share"
    cp -a usr/lib/cindy "$out/lib/cindy"
    cp -a usr/share/applications usr/share/pixmaps "$out/share/"
    substituteInPlace "$out/share/applications/cindy.desktop" \
      --replace-fail 'Exec=cindy %U' "Exec=$out/bin/cindy %U"

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/lib/cindy/Cindy" "$out/bin/cindy" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = {
    description = "Cindy AI agent desktop client (China edition)";
    homepage = "https://github.com/makecindy/cindy";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "cindy";
  };
}
