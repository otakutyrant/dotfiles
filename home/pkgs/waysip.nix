{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  glib,
  pango,
}:

# Package the Rust Wayland selector because it is not yet available in the
# pinned nixpkgs release. Its combined mode replaces Slurp for screenshots.
rustPlatform.buildRustPackage rec {
  pname = "waysip";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "waycrate";
    repo = "waysip";
    rev = "b234585439de04d762ad93018088629f91bdb665";
    hash = "sha256-kd3jovJXmRlz70LPlskS7nVo8TO+5UAVfTPEoPKXzYc=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    pango
  ];

  meta = {
    description = "Wayland-native area and output selector";
    homepage = "https://github.com/waycrate/waysip";
    license = lib.licenses.mit;
    mainProgram = "waysip";
    platforms = lib.platforms.linux;
  };
}
