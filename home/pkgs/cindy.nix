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

  # Select the international edition explicitly, regardless of host locale.
  src = fetchurl {
    url = "https://github.com/makecindy/cindy/releases/download/v${version}/cindy-${version}-linux-x64-global.deb";
    hash = "sha256-t1ZmPD8w1s+KddTY6jgzaEJomlBLaC1ixt09a6AeBmM=";
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

  # patchelf 0.15 moves libvips' .init without updating DT_INIT, crashing
  # Sharp at startup (NixOS/patchelf#639). Preserve this bundled library and
  # supply its C++ runtime through the launcher instead.
  dontAutoPatchelf = true;

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
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          stdenv.cc.cc.lib
          # Bundled ANGLE resolves native EGL through dlopen.
          libGL
        ]
      } \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  postFixup = ''
    addAutoPatchelfSearchPath "$out"
    mapfile -d "" -t patchTargets < <(
      find "$out" -type f ! -path '*/@img/sharp-libvips-linux-x64/lib/libvips-cpp.so.*' -print0
    )
    autoPatchelf --no-recurse -- "''${patchTargets[@]}"
  '';

  meta = {
    description = "Cindy AI agent desktop client (international edition)";
    homepage = "https://github.com/makecindy/cindy";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "cindy";
  };
}
