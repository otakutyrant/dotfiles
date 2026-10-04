{
  applyPatches,
  clipcat,
  rustPlatform,
}:

let
  # Clipcat republishes history through arboard, which embeds wl-clipboard-rs.
  # Use 0.9.4 so an abandoned receiver cannot clear a promoted large image.
  src = applyPatches {
    name = "clipcat-${clipcat.version}-wl-clipboard-rs-0.9.4-source";
    inherit (clipcat) src;
    patches = [ ./clipcat-wl-clipboard-rs-0.9.4.patch ];
  };
in
clipcat.overrideAttrs (_oldAttrs: {
  inherit src;

  # Replace the vendor derivation because overrideAttrs runs after
  # buildRustPackage has converted cargoHash into cargoDeps.
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-57fxsvFAJX59zYJBJ1Ddhue/TiKSPYxhEJ1MoUphvUc=";
  };
})
