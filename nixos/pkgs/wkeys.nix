{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  gtk4,
  gtk4-layer-shell,
  libxkbcommon,
}:

# wkeys is not packaged in the pinned nixpkgs release, so build its Rust GTK
# application from a fixed upstream revision. Keep Cargo's full workspace
# available for dependency resolution but only install the wkeys application.
rustPlatform.buildRustPackage {
  pname = "wkeys";
  version = "0.1.2-unstable-2026-02-16";

  src = fetchFromGitHub {
    owner = "ptazithos";
    repo = "wkeys";
    rev = "13ceae730f2433f3ac398224dafa539ae55d3f54";
    hash = "sha256-FFbSfKwNci0Z+CH8tXmLza5dvm14sviFIpZxMQuKzwo=";
  };

  cargoHash = "sha256-nCQVFxeasws1BGOtqyuwzlyKqu3mY76XUROmWVqt7gk=";
  cargoBuildFlags = [
    "-p"
    "wkeys"
  ];
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    libxkbcommon
  ];

  meta = {
    description = "On-screen keyboard for Wayland desktops";
    homepage = "https://github.com/ptazithos/wkeys";
    license = lib.licenses.mit;
    mainProgram = "wkeys";
    platforms = lib.platforms.linux;
  };
}
