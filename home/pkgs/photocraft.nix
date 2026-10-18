{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
  libX11,
  libxcb,
  libXcursor,
  libXi,
}:

# Upstream ships a binary tarball with the GUI, CLI, desktop entry, icons, and
# MIME metadata. Patch its conventional Linux binaries for the NixOS linker.
stdenvNoCC.mkDerivation rec {
  pname = "photocraft";
  version = "0.10.0";

  src = fetchurl {
    url = "https://github.com/storytold/photocraft/releases/download/v${version}/photocraft-${version}-linux-x86_64.tar.gz";
    hash = "sha256-xdRVeF2cLq9pW/jmMnxNbSOjnduVamEU8MW2Qyb5hOE=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    install -Dm755 bin/photocraft bin/photocraft-cli -t $out/bin
    cp -r share/. $out/share/

    runHook postInstall
  '';

  postFixup = ''
    # Winit and wgpu load these display and graphics libraries at runtime, so
    # autoPatchelf cannot discover them from the ELF dependency table.
    for program in photocraft photocraft-cli; do
      wrapProgram "$out/bin/$program" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            wayland
            libxkbcommon
            vulkan-loader
            libX11
            libxcb
            libXcursor
            libXi
          ]
        }"
    done
  '';

  meta = {
    description = "Image editor with layers, masks, and PSD support";
    homepage = "https://github.com/storytold/photocraft";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "photocraft";
    platforms = [ "x86_64-linux" ];
  };
}
