# Nur is packaged here so project flakes can reuse the same pinned task-runner
# release and the same stable nixpkgs package set as the dotfiles.
{
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  stdenv,
}:

stdenvNoCC.mkDerivation {
  pname = "nur";
  version = "0.30.2+0.115.1";

  src = fetchurl {
    url = "https://github.com/nur-taskrunner/nur/releases/download/v0.30.2%2B0.115.1/nur-0.30.2%2B0.115.1-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-z3tGydpAvg5uinfmZYH/fr6uB+nok2ajVK77C/tgDV4=";
  };

  sourceRoot = "nur-0.30.2+0.115.1-x86_64-unknown-linux-gnu";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 nur $out/bin/nur
    runHook postInstall
  '';
}
