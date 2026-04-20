-- This file handles nvim-treesitter and related plugins.

local nvim_treesitter = {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })
    end,
}

local nvim_treesitter_context = {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
}

return {
    nvim_treesitter,
    nvim_treesitter_context,
}
