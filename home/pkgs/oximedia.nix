{
  lib,
  rustPlatform,
  fetchCrate,
}:

# OxiMedia publishes a dedicated CLI crate whose executable is named
# `oximedia`; packaging that crate avoids building unrelated workspace tools.
rustPlatform.buildRustPackage {
  pname = "oximedia";
  version = "0.2.1";

  src = fetchCrate {
    pname = "oximedia-cli";
    version = "0.2.1";
    hash = "sha256-D+GGhPKwu3ih6EsWiCEPzO03Dxabo0LTD6SbLn6sPVk=";
  };

  cargoHash = "sha256-75J2ochVJdirDUcpmNUxV0oX9vaJUhyXCCP8Lm/gqZ4=";

  # Only compile the CLI binary. Upstream tests are not needed to install it.
  cargoBuildFlags = [
    "--bin"
    "oximedia"
  ];
  # Avoid LLVM's crashing high-optimization machine pass on this crate.
  CARGO_PROFILE_RELEASE_OPT_LEVEL = "1";
  doCheck = false;

  meta = {
    description = "Pure Rust multimedia processing command-line tool";
    homepage = "https://github.com/cool-japan/oximedia";
    license = lib.licenses.asl20;
    mainProgram = "oximedia";
    platforms = lib.platforms.linux;
  };
}
