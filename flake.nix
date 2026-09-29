{
  description = "otakutyrant dotfiles for NixOS and Home Manager";

  # Inputs are pinned in flake.lock so rebuilds remain reproducible.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Keep an unstable package set available for selected fast-moving tools
    # without moving the whole system away from the stable NixOS channel.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # Flake input keyword: `follows` makes Home Manager reuse this flake's
      # `nixpkgs` input instead of bringing a separate nixpkgs revision.
      # home-manager depends on nixpkgs so we reuse aforementioned nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      username = "otakutyrant";
      hostname = "nixos";
      # Selected tools are only available or fresh enough in the unstable channel.
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      # These arguments are needed by the shared Home Manager module.
      homeSpecialArgs = {
        inherit inputs username pkgs-unstable;
      };
    in
    {
      nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            username
            hostname
            pkgs-unstable
            ;
        };
        modules = [
          ./nixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = homeSpecialArgs;
            home-manager.users.${username} = import ./nixos/home.nix;
          }
        ];
      };

      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        # Standalone Home Manager needs unfree packages for this user profile.
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        extraSpecialArgs = homeSpecialArgs;
        modules = [ ./nixos/home.nix ];
      };
    };
}
