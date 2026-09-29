{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  glib-networking,
  pkg-config,
  wrapGAppsHook4,
  libxkbcommon,
  wayland,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
}:

# nmrs-gui is not packaged in the pinned nixpkgs release. Build the upstream
# GTK4 application from a fixed revision so it remains reproducible locally.
rustPlatform.buildRustPackage {
  pname = "nmrs-gui";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "networkmanager-rs";
    repo = "nmrs-gui";
    rev = "9ff7f8f3759e876b4488102c192a31886581020f";
    hash = "sha256-sA4D98pVdwu7vjxj4UOWBrT1GzMVxJc4ckoojmpIdaw=";
  };

  cargoHash = "sha256-/i9+33zs6wJWMZfjYhRg/SzYD0n7XuuD0FbbnOMyfQg=";

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libxkbcommon
    wayland
    glib
    gobject-introspection
    gtk4
    libadwaita
  ];

  doCheck = false;
  doInstallCheck = true;

  postInstall = ''
    install -D nmrs.desktop -t $out/share/applications
  '';

  meta = {
    description = "GTK4 GUI for managing NetworkManager connections";
    homepage = "https://github.com/networkmanager-rs/nmrs-gui";
    license = lib.licenses.mit;
    mainProgram = "nmrs-gui";
    platforms = lib.platforms.linux;
  };
}
