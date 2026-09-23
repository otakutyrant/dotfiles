{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  python3,
  libX11,
  libXrandr,
  libxcb,
}:

# Build Hacksaw's published X11 selector crate. It prints the selected region
# as geometry, which the screenshot script passes to `shotgun`.
rustPlatform.buildRustPackage {
  pname = "hacksaw";
  version = "1.0.4";

  src = fetchCrate {
    pname = "hacksaw";
    version = "1.0.4";
    hash = "sha256-HRYTiccXU8DboAwZAr2gfzXUs8igSiFDpOEGtHpI0dA=";
  };

  # The published crate has a v1 lockfile with checksums stored separately.
  # Keep a normalized v3 lockfile so modern Nix vendoring can verify crates.
  cargoLock.lockFile = ./hacksaw-Cargo.lock;
  postPatch = ''
    cp ${./hacksaw-Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    python3
  ];
  buildInputs = [
    libX11
    libXrandr
    libxcb
  ];

  # Package installation only needs a successful compile; don't run upstream
  # tests as part of the user's system rebuild.
  doCheck = false;

  meta = {
    description = "Interactive region selector for X11";
    homepage = "https://github.com/neXromancers/hacksaw";
    license = lib.licenses.mpl20;
    mainProgram = "hacksaw";
    platforms = lib.platforms.linux;
  };
}
