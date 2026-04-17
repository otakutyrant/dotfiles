-- This file handles nvim-treesitter and related plugins.

local nvim_treesitter = {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
        ensure_installed = {
            "bash",
            "c",
            "css",
            "diff",
            "gitcommit",
            "gitignore",
            "html",
            "javascript",
            "jsdoc",
            "json",
            "jsonc",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "nix",
            "python",
            "query",
            "regex",
            "toml",
            "tsx",
            "typescript",
            "vim",
            "vimdoc",
            "yaml",
        },
        auto_install = true,
        highlight = { enable = true },
    },
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
