{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

let
  version = "0.1.4";
in
rustPlatform.buildRustPackage {
  pname = "rtrash";
  inherit version;

  src = fetchFromGitHub {
    owner = "HaoZeke";
    repo = "rtrash";
    tag = "v${version}";
    hash = "sha256-c/wN9ljxF/Pn4pha5DwoPIoB0R62L4OM+HFW78XwdW4=";
  };

  cargoHash = "sha256-GW4lh9KtstAvXcBPl0Tn+utoV+nObtFO7vCQK+du33c=";

  # Joshuto invokes the trash-cli-compatible multi-call name directly.
  postInstall = ''
    for command in trash-put trash-list trash-restore trash-empty trash-rm trash; do
      ln -s $out/bin/rtrash $out/bin/$command
    done
  '';

  meta = {
    description = "Fast FreeDesktop trash tool with an rm-compatible interface";
    homepage = "https://github.com/HaoZeke/rtrash";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rtrash";
  };
}
