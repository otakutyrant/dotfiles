{
  pkgs,
  username,
  ...
}:

{
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "docker"
      "networkmanager"
      "uinput"
      "wheel"
    ];
    # The login shell must be installed by NixOS because /etc/passwd points to
    # its store path. Home Manager separately configures the same Nushell.
    shell = pkgs.nushell;
  };
}
