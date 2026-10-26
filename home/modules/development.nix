{
  config,
  pkgs,
  ...
}:

{
  # Editors, language tooling, compilers, and developer services.
  home.packages = [
    ## Editor
    pkgs.neovim
    pkgs.python3Packages.pynvim

    ## Agent
    # Install Kimi Code CLI from MoonshotAI's own flake because it is not
    # provided by the pinned NixOS 26.05 nixpkgs package set. It provides the
    # `kimi` command and replaces the legacy Python-based kimi-cli.
    config.programs.codex.package # Codex CLI.
    pkgs.local.chatgpt # ChatGPT desktop app.
    pkgs.unstable.opencode # Open AI harness.

    ## Database
    pkgs.postgresql
    pkgs.prisma-engines # Provides Prisma schema-engine for NixOS.
    pkgs.prisma-language-server

    ## Python
    pkgs.python3
    pkgs.uv # Package manager.

    ## TypeScript
    pkgs.typescript
    # Stay on pnpm 10 for Kimi Code compatibility while receiving security fixes.
    pkgs.pnpm_10_latest # NPM package manager.
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.tailwindcss-language-server

    ## Rust
    pkgs.rustup

    ## C/C++
    pkgs.gcc # Provides `cc` for tools that expect a compiler on PATH.

    ## Lua
    pkgs.lua
    pkgs.stylua
    pkgs.lua-language-server

    ## Nix, note that installing Nix causes conflicts, so it is not included here.
    pkgs.nixd
    pkgs.nixfmt

    ## YAML
    pkgs.yamlfmt
    pkgs.yaml-language-server

    ## TOML
    pkgs.taplo

    ## SAST
    pkgs.codeql

    ## Command sandbox
    # sandbox constructs a minimal filesystem view for untrusted projects.
    pkgs.bubblewrap
  ];
}
