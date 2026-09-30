{ pkgs }:

# Replace named placeholders in a source file with values known during Nix
# evaluation, such as package executables and paths in the Nix store.
source: substitutions: pkgs.replaceVars source substitutions
