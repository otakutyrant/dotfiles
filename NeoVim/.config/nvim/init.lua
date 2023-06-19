require('config.editor')

-- Make sure that lazy.vim is automatically installed as the plugin manager.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Deploy plugins.
require("lazy").setup({
    {'folke/tokyonight.nvim'},
})

-- Enable 24-bit RGB color in the TUI, which is better than the tranditional 256 term colors.
vim.opt.termguicolors = true
-- Use tokyonight theme.
vim.cmd.colorscheme('tokyonight')
