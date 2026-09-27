{
  lib,
  rustPlatform,
  fetchCrate,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  gtk4-layer-shell,
}:

# Build the Rust notification daemon from a fixed crates.io release. GTK's
# wrapper supplies the GSettings and icon paths needed outside a full desktop.
rustPlatform.buildRustPackage {
  pname = "nwg-notifications";
  version = "0.7.0";

  src = fetchCrate {
    pname = "nwg-notifications";
    version = "0.7.0";
    hash = "sha256-Hgr6lrtpvyO1JEY+WW5K1kdkkU65KFWU13TjNoiE5jY=";
  };

  cargoHash = "sha256-wOkPp3KY/8lRPK7Q3O07EBsGzS4YP7Mks+0pc2iMn8Q=";

  # Upstream limits titles to one line and GTK themes can wash out action
  # labels. Fix both in the package so no per-user theme file is needed.
  patches = [ ./nwg-notifications-popup.patch ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
  ];

  meta = {
    description = "Rust notification daemon and history panel for Sway";
    homepage = "https://github.com/jasonherald/nwg-notifications";
    license = lib.licenses.mit;
    mainProgram = "nwg-notifications";
    platforms = lib.platforms.linux;
  };
}
