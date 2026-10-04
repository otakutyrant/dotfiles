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
      unstablePackages = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      # Expose repository-local packages under `pkgs.local` without replacing
      # similarly named packages from nixpkgs, such as GNU Tree.
      localPackagesOverlay = final: _previous: {
        # Make the secondary package set available through the ordinary `pkgs`
        # argument instead of passing a separate module argument everywhere.
        unstable = unstablePackages;

        local = {
          chatgpt = final.callPackage ./home/pkgs/chatgpt.nix { };
          clipcat = final.callPackage ./home/pkgs/clipcat.nix { };
          imageflow = final.callPackage ./home/pkgs/imageflow.nix { };
          kimi-code = final.callPackage ./home/pkgs/kimi-code.nix { };
          nmrs = final.callPackage ./home/pkgs/nmrs.nix { };
          nur = final.callPackage ./home/pkgs/nur.nix { };
          nutstore = final.callPackage ./home/pkgs/nutstore.nix { };
          oximedia = final.callPackage ./home/pkgs/oximedia.nix { };
          tree = final.callPackage ./home/pkgs/tree.nix { };
          wayshot = final.callPackage ./home/pkgs/wayshot.nix { };
          waysip = final.callPackage ./home/pkgs/waysip.nix { };
          wdotool = final.callPackage ./home/pkgs/wdotool.nix { };
          wkeys = final.callPackage ./home/pkgs/wkeys.nix { };
          wl-clipboard-rs = final.callPackage ./home/pkgs/wl-clipboard-rs.nix { };

          # Sway 1.12 fixes layer-shell popup repositioning, which GTK's
          # sliding tray submenus require near the bottom edge of an output.
          sway = unstablePackages.sway;

          # Fast-moving packages intentionally come from unstable nixpkgs.
          nwg-notifications = unstablePackages.callPackage ./home/pkgs/nwg-notifications.nix { };
        };
      };
      # These arguments are needed by the shared Home Manager module.
      homeSpecialArgs = {
        inherit username;
      };
    in
    {
      nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            username
            hostname
            ;
        };
        modules = [
          ./nixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ localPackagesOverlay ];
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = homeSpecialArgs;
            home-manager.users.${username} = import ./home/configuration.nix;
          }
        ];
      };

      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        # Standalone Home Manager needs unfree packages for this user profile.
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ localPackagesOverlay ];
        };
        extraSpecialArgs = homeSpecialArgs;
        modules = [ ./home/configuration.nix ];
      };
    };
}
