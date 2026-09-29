{
  pkgs,
  pkgs-unstable,
  ...
}:

# Editors, language tooling, compilers, and developer services.
with pkgs;
[
  ## Editor
  neovim
  python3Packages.pynvim

  ## Agent
  # Install Kimi Code CLI from MoonshotAI's own flake because it is not
  # provided by the pinned NixOS 26.05 nixpkgs package set. It provides the
  # `kimi` command and replaces the legacy Python-based kimi-cli.
  (callPackage ../pkgs/kimi-code.nix { }) # Kimi Code CLI.
  pkgs-unstable.opencode # Open AI harness.
  (callPackage ../pkgs/chatgpt.nix { }) # ChatGPT desktop app.

  ## Database
  postgresql
  prisma-engines # Provides Prisma schema-engine for NixOS.
  prisma-language-server

  ## Python
  python3
  uv # Package manager.

  ## TypeScript
  typescript
  pnpm # NPM package manager.
  typescript-language-server
  vscode-langservers-extracted
  tailwindcss-language-server

  ## Rust
  rustup

  ## C/C++
  gcc # Provides `cc` for tools that expect a compiler on PATH.

  ## Lua
  lua
  stylua
  lua-language-server

  ## Nix, note that installing Nix causes conflicts, so it is not included here.
  nixd
  nixfmt

  ## YAML
  yamlfmt
  yaml-language-server

  ## TOML
  taplo

  ## SAST
  codeql

  ## Sandbox container
  bubblewrap # Provides the `bwrap` command for creating sandboxed processes.
]
