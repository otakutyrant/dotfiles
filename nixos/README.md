# NixOS usage

This repository is managed through a Nix flake for NixOS and Home Manager.

## Fresh NixOS system

Clone the repository with submodules:

```sh
git clone --recursive https://github.com/otakutyrant/dotfiles.git /etc/nixos/dotfiles
cd /etc/nixos/dotfiles
```

Build the bundled host configuration:

```sh
nixos-rebuild switch --flake .#nixos
passwd otakutyrant
```

The NixOS configuration creates the `otakutyrant` user, enables flakes,
NetworkManager, Docker, PipeWire, fcitx5, NVIDIA graphics, LightDM, and i3. It
imports `/etc/nixos/hardware-configuration.nix` when that file exists.

## Home Manager only

If the system user already exists and Home Manager is installed:

```sh
home-manager switch --flake .#otakutyrant
```

## Notes

System options live in `nixos/configuration.nix`. User packages live in
`nixos/home-packages.nix`, with local package derivations under `nixos/pkgs`.

The Home Manager module links the existing dotfiles instead of translating every
application config into Nix options. This keeps the current layout usable while
letting NixOS manage the user, packages, services, and desktop session.
