-- This file handles nvim-treesitter and related plugins.
-- The plugin nvim-treesitter add features to Neovim or enhance default features, like highlight.

local nvim_treesitter = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    -- Automatically update all parsers when the plugin is installed or updated.
    build = ":TSUpdate",
    opts = {
        -- Install all parsers.
        ensure_installed = "all",
        highlight = { enable = true },
    },
}

-- Show the context of the currently visible buffer contents when you scroll.
local nvim_treesitter_context = {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
}

-- TODO: find out what is the point of nvim-treesitter-textobjects and whether to use it.

return {
    nvim_treesitter,
    nvim_treesitter_context,
}
