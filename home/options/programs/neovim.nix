{
  config,
  lib,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  # Neovim remains installed as an unwrapped package by the development module.
  # Keep its complete Lua configuration as source files so it preserves the
  # normal runtime layout under ~/.config/nvim.
  xdg.configFile."nvim" = {
    source = ../../files/config/nvim;
    recursive = true;
  };

  # Store-backed source files have epoch mtimes. Clear vim.loader's compiled
  # cache after activation so a new generation cannot reuse stale Lua bytecode.
  home.activation.clearNvimLuacCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -rf ${home}/.cache/nvim/luac
  '';
}
