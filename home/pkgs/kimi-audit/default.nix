{
  lib,
  writeText,
  writeScriptBin,
  closureInfo,
  kimi,
  python3,
  bubblewrap,
  nushell,
  bash,
  ripgrep,
  fd,
  gitMinimal,
  gnused,
  findutils,
  coreutils,
  cacert,
  systemd,
  libnotify,
}:
let
  # Keep build/test caches out of the executable package.
  scripts = lib.cleanSourceWith {
    src = ./.;
    filter = path: _type: builtins.baseNameOf path != "__pycache__";
  };
  bins = {
    kimi = "${kimi}/bin/kimi";
    python3 = "${python3}/bin/python3";
    bwrap = "${bubblewrap}/bin/bwrap";
    nu = "${nushell}/bin/nu";
    bash = "${bash}/bin/bash";
    rg = "${ripgrep}/bin/rg";
    fd = "${fd}/bin/fd";
    git = "${gitMinimal}/bin/git";
    sed = "${gnused}/bin/sed";
    find = "${findutils}/bin/find";
  };
  # Mount only selected runtime dependencies, not the host's entire Nix store.
  closure = closureInfo {
    rootPaths = [
      kimi
      python3
      bubblewrap
      nushell
      bash
      ripgrep
      fd
      gitMinimal
      gnused
      findutils
      coreutils
    ];
  };
  runtime = writeText "kimi-audit-runtime.json" (
    builtins.toJSON {
      inherit bins scripts;
      storesFile = "${closure}/store-paths";
      coreutils = "${coreutils}/bin";
      caFile = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      systemctl = "${systemd}/bin/systemctl";
      # Desktop notifications run on the host, outside the audit sandbox.
      notifySend = "${libnotify}/bin/notify-send";
    }
  );
in
# Nushell is the public entry point; Python handles HTTP, snapshots and locking.
writeScriptBin "kimi-audit" ''
  #!${nushell}/bin/nu --no-config-file
  def --wrapped main [...args: string] {
    with-env { PYTHONDONTWRITEBYTECODE: "1", PYTHONUNBUFFERED: "1" } {
      ^${nushell}/bin/nu --no-config-file ${scripts}/run.nu ${runtime} ...$args
      exit $env.LAST_EXIT_CODE
    }
  }
''
