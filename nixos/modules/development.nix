{ username, ... }:

{
  # nix-ld allows prebuilt development tools that expect a conventional Linux
  # dynamic linker to run without adding Nix itself to the system packages.
  programs.nix-ld.enable = true;
  virtualisation.docker.enable = true;

  services.postgresql = {
    enable = true;
    # Prisma resets these project schemas, so the normal user must own them.
    ensureDatabases = [
      # ensureDBOwnership requires a database with the same name as the role.
      username
      "ci_development"
      "ci_test"
    ];
    ensureUsers = [
      {
        name = username;
        ensureClauses.createdb = true;
        ensureDBOwnership = true;
      }
    ];
  };

  # The NixOS ownership helper only handles the role's same-name database, so
  # repair ownership of the two custom project databases on every start.
  systemd.services.postgresql.postStart = ''
    psql --dbname postgres --command 'ALTER DATABASE "ci_development" OWNER TO "${username}";'
    psql --dbname postgres --command 'ALTER DATABASE "ci_test" OWNER TO "${username}";'
  '';
}
