#!/usr/bin/env nu
def main [version: string, --build] {
    let script_dir = ($env.CURRENT_FILE | path dirname | path expand)
    let repo_dir = ($script_dir | path join ../.. | path expand)
    let package_file = ($script_dir | path join nfcloud.nix | path expand)
    let url = "https://backendoss.trafficmanager.net/api/v1/app/get/nfcloud/linux"
    let hash_base32 = (nix-prefetch-url --type sha256 $url | lines | first)
    let hash_sri = (nix hash convert --hash-algo sha256 --to sri $hash_base32 | str trim)
    open --raw $package_file | str replace --regex 'version = "[^"]+";' $"version = \"($version)\";" | str replace --regex 'hash = "sha256-[^"]+";' $"hash = \"($hash_sri)\";" | save --force $package_file
    nix-instantiate --parse $package_file | ignore
    if $build {
        let expr = $"
      let
        flake = builtins.getFlake \(toString ($repo_dir)/.\);
        pkgs = import flake.inputs.nixpkgs {
          system = \"x86_64-linux\";
          config.allowUnfree = true;
        };
      in
        pkgs.callPackage ($package_file) { }
    "
        nix build --impure --expr $expr
    }
    print $"nfcloud updated to ($version) with hash ($hash_sri)"
}
