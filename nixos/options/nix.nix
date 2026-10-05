{ ... }:

{
  # Configure Nix itself separately from the packages and services it builds.
  nix.settings = {
    # Use XDG state directories for profiles, including the user profile under
    # ~/.local/state/nix/profile.
    use-xdg-base-directories = true;
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos-cuda.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    experimental-features = [
      "nix-command" # Enable commands such as nix shell and nix build.
      "flakes"
    ];
    # The dotfiles are often evaluated while edits are still in progress.
    warn-dirty = false;
  };

  # A better Nix helper.
  programs.nh = {
    enable = true;
    # Let nh find this configuration without requiring --flake on each run.
    flake = "/home/otakutyrant/Projects/dotfiles";
  };

  # The daemon does not inherit the interactive user's proxy environment.
  systemd.services.nix-daemon.environment = rec {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = http_proxy;
    HTTP_PROXY = http_proxy;
    HTTPS_PROXY = http_proxy;
    all_proxy = "socks5://127.0.0.1:7890";
    ALL_PROXY = all_proxy;
    no_proxy = builtins.concatStringsSep "," [
      "localhost"
      "127.0.0.1"
      "::1"
      "mirrors.tuna.tsinghua.edu.cn"
      "mirrors.ustc.edu.cn"
      "mirror.sjtu.edu.cn"
    ];
    NO_PROXY = no_proxy;
  };

  # System modules such as Steam and NVIDIA still require unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Trim old generations before they consume the Nix store indefinitely.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
