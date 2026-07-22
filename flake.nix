/**
  A flake is a Nix project with a standard interface.
  `inputs` declares the project's dependencies, `outputs` declares what the
  project exports, and flake.lock pins the exact resolved dependency versions.
*/

# The top-level attribute set.
{
  # Flake-specific top-level keyword: `description` is optional metadata. Nix
  # shows it in flake metadata output, but it does not affect evaluation.
  description = "otakutyrant dotfiles for NixOS and Home Manager";

  # Flake-specific top-level keyword: `inputs` declares external flakes. These
  # inputs are pinned in flake.lock so rebuilds use reproducible versions until
  # the lock file is updated.
  inputs = {
    # Flake input keyword: `url` tells Nix where to fetch the `nixpkgs` input.
    # nixpkgs is the main package collection and module library used by Nix
    # and NixOS.
    # This line defines `nixpkgs` and `url` at them same time. That said, it is
    # equivalent to `nixpkgs = { url = "..." };`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Define the `home-manager` flake input.
    home-manager = {
      # Flake input keyword: `url` tells Nix where to fetch Home Manager.
      url = "github:nix-community/home-manager/release-26.05";
      # Flake input keyword: `follows` makes Home Manager reuse this flake's
      # `nixpkgs` input instead of bringing a separate nixpkgs revision.
      # home-manager depends on nixpkgs so we reuse aforementioned nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake-specific top-level keyword: `outputs` is the function that returns
  # values exported by this flake. Commands such as `nixos-rebuild --flake` and
  # `home-manager switch --flake` look here for named configurations.
  outputs =
    # `inputs@{ ... }` destructures the flake inputs like an object parameter
    # while also keeping the whole input set available as `inputs`.
    # `{ ... }` is the general function arguments part.
    inputs@{ home-manager, nixpkgs, ... }:
    # `let` starts private local bindings for this function body; these names
    # are helpers, not attributes exported by the flake.
    let
      system = "x86_64-linux";
      username = "otakutyrant";
      hostname = "nixos";
      # `in` starts the expression that can use the local names defined above.
      # The whole `let ... in ...` expression evaluates to the value after `in`.
    in
    # This attribute set is the actual value returned by `outputs`.
    {
      # Flake output keyword: `nixosConfigurations` exposes full NixOS machine
      # configurations used by `nixos-rebuild --flake`.
      # nixpkgs.lib.nixosSystem is a function that accepts system, specialArgs,
      # modules.
      # nixpkgs.lib.nixosSystem merges `moudles`.
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        # It is equivalent to `system = system`.
        inherit system;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs username; };
            # nixosConfigurations.${hostname} resues the home.nix here.
            home-manager.users.${username} = import ./nixos/home.nix;
          }
        ];
      };

      # Flake output keyword used by Home Manager: `homeConfigurations` exposes
      # standalone user profiles for `home-manager switch --flake`.
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Standalone Home Manager needs a package set, so import Nixpkgs at the
        # call site instead of keeping a separate local `pkgs` binding.
        pkgs = import nixpkgs {
          # `inherit system;` is shorthand for `system = system;`.
          inherit system;
          # Allow proprietary/unfree packages in this imported package set.
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs username; };
        modules = [ ./nixos/home.nix ];
      };
    };
}
