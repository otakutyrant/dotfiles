{
  lib,
  fetchFromGitHub,
  stdenv,
  fetchPnpmDeps,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
  ripgrep,
  fd,
}:

let
  # Kimi Code's native executable requires Node.js 24.15.0 or newer.
  nodejs = nodejs_24;
  pnpm = pnpm_10.override { inherit nodejs; };
  src = fetchFromGitHub {
    owner = "MoonshotAI";
    repo = "kimi-code";
    rev = "0523bafb39101d471683f4f53e052767f3add2ef";
    hash = "sha256-nq7HwY1rskKqOtfs/fMGItH+WZbAhAagPkQ7NEtaN1w=";
  };
  appPackage = builtins.fromJSON (builtins.readFile "${src}/apps/kimi-code/package.json");
  nativeTarget = "linux-x64";
  workspaceNames = [
    "@moonshot-ai/acp-server"
    "@moonshot-ai/agent-core-v2"
    "@moonshot-ai/kap-server"
    "@moonshot-ai/kaos"
    "@moonshot-ai/kosong"
    "@moonshot-ai/migration-legacy"
    "@moonshot-ai/minidb"
    "@moonshot-ai/kimi-code-sdk"
    "@moonshot-ai/kimi-code-oauth"
    "@moonshot-ai/klient"
    "@moonshot-ai/pi-tui"
    "@moonshot-ai/remote-control"
    "@moonshot-ai/kimi-telemetry"
    "@moonshot-ai/transcript"
    "@moonshot-ai/tree-sitter-bash"
    "@moonshot-ai/kimi-code"
    "kimi-code"
    "@moonshot-ai/kimi-inspect"
    "@moonshot-ai/vis"
    "@moonshot-ai/vis-server"
    "@moonshot-ai/vis-web"
    "kimi-code-docs"
  ];
  pnpmWorkspaces = [ "." ] ++ workspaceNames;
in

stdenv.mkDerivation {
  pname = "kimi-code";
  version = appPackage.version;
  inherit src;

  pnpmDeps = fetchPnpmDeps {
    pname = "kimi-code";
    inherit (appPackage) version;
    inherit src pnpm pnpmWorkspaces;
    fetcherVersion = 3;
    hash = "sha256-xrn34bQ76s+ouOZPHZ4TBkpTHxG7gZejmx8RqSii2uA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    (pnpmConfigHook.override { inherit pnpm; })
    makeWrapper
  ];

  dontStrip = true;

  buildPhase = ''
    runHook preBuild
    export KIMI_CODE_BUILD_TARGET=${nativeTarget}
    node apps/kimi-code/scripts/check-web-assets.mjs
    pnpm --filter=@moonshot-ai/kimi-code run build:native:sea
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 \
      "apps/kimi-code/dist-native/bin/${nativeTarget}/kimi" \
      "$out/bin/kimi"
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/kimi --prefix PATH : ${
      lib.makeBinPath [
        ripgrep
        fd
      ]
    }
  '';

  meta = {
    description = "Kimi Code CLI";
    homepage = "https://github.com/MoonshotAI/kimi-code";
    license = lib.licenses.mit;
    mainProgram = "kimi";
    platforms = [ "x86_64-linux" ];
  };
}
