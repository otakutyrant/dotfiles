{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "tree";
  version = "1.3.0-unstable-2026-03-14";

  src = fetchFromGitHub {
    owner = "otakutyrant";
    repo = "tree";
    rev = "0707bdfb050471a198886751e6c540556ac66c0e";
    hash = "sha256-MiHZJeiAZnr7ybk7fvMzOHF6IVHnX4jkH+ru/ENoXws=";
  };

  cargoHash = "sha256-p20ej7ohJSv28+FDrRPhdLQFCuovKOC2+XHEdHbWSt4=";

  meta = with lib; {
    description = "Recursive directory listing tool (otakutyrant's Rust fork)";
    homepage = "https://github.com/otakutyrant/tree";
    license = licenses.mit;
    mainProgram = "tree";
    platforms = platforms.all;
  };
}
