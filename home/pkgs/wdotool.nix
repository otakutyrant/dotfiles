{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  libxkbcommon,
  wayland,
}:

# wdotool is not in the pinned nixpkgs release. Its upstream flake at this
# revision has a workspace-version parsing bug, so package the same locked
# source directly with buildRustPackage.
rustPlatform.buildRustPackage {
  pname = "wdotool";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "cushycush";
    repo = "wdotool";
    rev = "662d7079b669de164797f46fd437c0cf7854bf82";
    hash = "sha256-V0DOznaptdFrNxtTpJZtJIVikZTXa9zacNFWceGAu+o=";
  };

  cargoHash = "sha256-0sifatYl+aGX+on2mXlMJg7/zKjpORNV3pEv9ZcdZZI=";
  cargoBuildFlags = [
    "-p"
    "wdotool"
  ];
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libxkbcommon
    wayland
  ];

  meta = {
    description = "xdotool-compatible input automation for Wayland";
    homepage = "https://github.com/cushycush/wdotool";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "wdotool";
    platforms = lib.platforms.linux;
  };
}
