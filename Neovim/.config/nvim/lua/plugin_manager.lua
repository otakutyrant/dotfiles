-- Define the path to lazy.nvim installation directory
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if lazy.nvim is already installed
-- Use vim.uv (for Neovim >= 0.10)
if not vim.uv.fs_stat(lazypath) then
    -- Define the Git repository URL for lazy.nvim
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"

    -- Clone the lazy.nvim repository using git
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none", -- Skip downloading blob objects for faster clone
        "--branch=stable", -- Use the latest stable release branch
        lazyrepo,
        lazypath,
    })

    -- If the clone failed, display an error and exit Neovim
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

-- Prepend lazy.nvim to runtime path so Neovim can find it
vim.opt.rtp:prepend(lazypath)

-- These leader keys must be set before the lazy setup, but I have set them elsewhere, so just insure it here
if vim.g.mapleader == "" or vim.g.maplocalleader == "" then
    vim.api.nvim_echo({
        { "Error: mapleader or maplocalleader is not set.\n", "ErrorMsg" },
        { "Please set them before using lazy.nvim.\n", "ErrorMsg" },
        { "\nExiting Neovim..." },
    }, true, {})
    os.exit(1)
end

-- Load and configure lazy.nvim
require("lazy").setup("plugins")
