{
  config,
  lib,
  ...
}:

{
  # Neovim remains installed as an unwrapped package by the development module.
  # Keep its complete Lua configuration as source files so it preserves the
  # normal runtime layout under ~/.config/nvim.
  xdg.configFile."nvim" = {
    source = ../../files/config/nvim;
    recursive = true;
  };

  # Clear compiled Lua entries during activation because fixed Nix store mtimes
  # can make stale bytecode appear current.
  #
  # Keep the cache directory itself. Home Manager may activate while Neovim is
  # still open, and vim.loader creates this directory only when the loader is
  # enabled. Removing the directory from beneath that process makes the next
  # lazy Lua load, such as the Markdown filetype plugin, fail with ENOENT when
  # it tries to write new bytecode.
  home.activation.clearNvimLuacCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    nvim_luac_cache=${lib.escapeShellArg "${config.xdg.cacheHome}/nvim/luac"}
    mkdir -p "$nvim_luac_cache"
    find "$nvim_luac_cache" -mindepth 1 -maxdepth 1 -delete
  '';
}
