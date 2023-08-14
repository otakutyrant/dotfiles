-- The "firstly-recommended" plugin.
local fugitive = {
    "tpope/vim-fugitive",
}

-- Show signs for added, removed, and changed lines.
local gitsigns = {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({})
    end,
}

local foldsigns = {
    "lewis6991/foldsigns.nvim",
    config = function()
        require("foldsigns").setup()
    end,
}

return {
    fugitive,
    gitsigns,
    foldsigns,
}
