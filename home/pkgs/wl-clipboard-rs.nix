{
  fetchFromGitHub,
  rustPlatform,
  wl-clipboard-rs,
}:

# Version 0.9.4 keeps clipboard ownership when one paste destination closes
# early. Remove this override after the pinned nixpkgs includes PR #567758.
let
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = "wl-clipboard-rs";
    rev = "v${version}";
    hash = "sha256-7eJ4V0Wr71bdH5+Smc2KAaK06i2/YpJtlis+vqwUY5w=";
  };
in
wl-clipboard-rs.overrideAttrs (_oldAttrs: {
  inherit version src;

  # buildRustPackage has already converted cargoHash into cargoDeps by the time
  # overrideAttrs runs, so replace the vendored dependency derivation directly.
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-NYVtztI5lYlRDNg2eNQyoEn7q43Yybdn2oq+srnVbeY=";
  };
})
