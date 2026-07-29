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
      pkgs = nixpkgs.legacyPackages.${system};
      # Flake apps need a small wrapper object. Keeping it local avoids
      # repeating the same `type = "app"` boilerplate for each project command.
      mkApp = program: {
        type = "app";
        program = "${program}/bin/${program.name}";
      };
      # These wrappers keep code-quality commands reproducible through the
      # pinned nixpkgs input. The scripts themselves are Nushell because this
      # repository already uses Nushell for project automation.
      qualityScripts =
        let
          script =
            name: text:
            pkgs.writeTextFile {
              inherit name;
              destination = "/bin/${name}";
              executable = true;
              text = ''
                #!${pkgs.nushell}/bin/nu

                ${text}
              '';
            };
          # Only checked-in files are constrained. Deleted paths are ignored so
          # the tools still work during rename-heavy changes.
          common = ''
            def tracked-files [extension: string] {
                ^${pkgs.git}/bin/git ls-files
                | lines
                | where { |path| ($path | str ends-with $extension) and ($path | path exists) }
            }

            def nix-files [] {
                tracked-files ".nix"
                | where { |path| $path != "nixos/hardware-configuration.nix" }
            }

            def lua-files [] {
                tracked-files ".lua"
            }

            def nu-files [] {
                tracked-files ".nu"
            }
          '';
        in
        rec {
          format = script "dotfiles-format" ''
            ${common}

            let nix_files = (nix-files)
            if ($nix_files | is-not-empty) {
                ^${pkgs.nixfmt}/bin/nixfmt ...$nix_files
            }

            let lua_files = (lua-files)
            if ($lua_files | is-not-empty) {
                ^${pkgs.stylua}/bin/stylua ...$lua_files
            }
          '';
          lint = script "dotfiles-lint" ''
            ${common}

            let nix_files = (nix-files)
            if ($nix_files | is-not-empty) {
                ^${pkgs.nixfmt}/bin/nixfmt --check ...$nix_files
            }

            let lua_files = (lua-files)
            if ($lua_files | is-not-empty) {
                ^${pkgs.stylua}/bin/stylua --check ...$lua_files
            }
          '';
          typecheck = script "dotfiles-typecheck" ''
            ${common}

            # Nix does not have a separate type checker. Evaluating these
            # derivation paths checks that the flake, NixOS modules, and Home
            # Manager module type-check without building the resulting systems.
            ^${pkgs.nix}/bin/nix eval --no-update-lock-file --raw .#nixosConfigurations.${hostname}.config.system.build.toplevel.drvPath | ignore
            ^${pkgs.nix}/bin/nix eval --no-update-lock-file --raw .#homeConfigurations.${username}.activationPackage.drvPath | ignore

            # lua-language-server is the practical Lua checker already used by
            # editor tooling. Only Error diagnostics fail this command.
            ^${pkgs.lua-language-server}/bin/lua-language-server --check . --checklevel Error --check_format pretty --logpath /tmp/dotfiles-lua-language-server-log

            # Nushell autoload files must be sourceable. `nu --ide-check` can
            # miss errors that only appear when an autoload file is sourced, so
            # source those files directly and reserve IDE parsing for scripts
            # that may have side effects when executed.
            for file in (nu-files | where { |path| $path | str starts-with "Nushell/.config/nushell/autoload/" }) {
                ^${pkgs.nushell}/bin/nu -n -c $"source ($file)"
            }

            for file in (nu-files) {
                ^${pkgs.nushell}/bin/nu --ide-check 0 $file | ignore
            }
          '';
          check = script "dotfiles-check" ''
            ^${lint}/bin/dotfiles-lint
            ^${typecheck}/bin/dotfiles-typecheck
          '';
        };
      # `in` starts the expression that can use the local names defined above.
      # The whole `let ... in ...` expression evaluates to the value after `in`.
    in
    # This attribute set is the actual value returned by `outputs`.
    {
      # Flake output keyword: `formatter` lets `nix fmt` choose the formatter
      # for this system automatically.
      formatter.${system} = qualityScripts.format;

      # Flake app outputs make the same constraints explicit and scriptable:
      # `nix run .#format`, `nix run .#lint`, `nix run .#typecheck`, and
      # `nix run .#check`.
      apps.${system} = {
        format = mkApp qualityScripts.format;
        lint = mkApp qualityScripts.lint;
        typecheck = mkApp qualityScripts.typecheck;
        check = mkApp qualityScripts.check;
      };

      # A dev shell keeps the formatter, linter, and diagnostic tools available
      # for direct editor or terminal use outside the flake app wrappers.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          lua-language-server
          nixfmt
          nushell
          pre-commit
          stylua
        ];
      };

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
        # Standalone Home Manager needs a package set with unfree packages
        # enabled, because this user profile installs proprietary software.
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
