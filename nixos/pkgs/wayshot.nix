{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  installShellFiles,
  scdoc,
  pango,
  wayland,
}:

# Build wayshot from the merged upstream revision so this system gets the
# BGR888 stride fix before the next nixpkgs release.
rustPlatform.buildRustPackage rec {
  pname = "wayshot";
  version = "1.6.0-unstable-2026-09-27";

  src = fetchFromGitHub {
    owner = "waycrate";
    repo = "wayshot";
    rev = "cd5a998323953967720a8de02bf165236bff6388";
    hash = "sha256-KhgWYA3heqRHQ8g4jdGEZboHRtUL7lYeK4hYwqxZ+ME=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  # Keep the same feature set as the upstream Nix package.
  buildNoDefaultFeatures = true;
  buildFeatures = [
    "jpeg"
    "pnm"
    "qoi"
    "webp"
    "avif"
    "jxl"
    "clipboard"
    "color_picker"
    "completions"
    "logger"
    "notifications"
    "selector"
  ];

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    scdoc
  ];

  buildInputs = [
    pango
    wayland
  ];

  postInstall = ''
    installManPage docs/wayshot.1.gz docs/wayshot.5.gz docs/wayshot.7.gz
    installShellCompletion --cmd wayshot \
      --bash <($out/bin/wayshot --completions bash) \
      --fish <($out/bin/wayshot --completions fish) \
      --zsh <($out/bin/wayshot --completions zsh) \
      --nushell <($out/bin/wayshot --completions nushell)
  '';

  meta = {
    description = "Screenshot tool for Wayland compositors";
    homepage = "https://github.com/waycrate/wayshot";
    license = lib.licenses.gpl3Plus;
    mainProgram = "wayshot";
    platforms = lib.platforms.linux;
  };
}
