-- The "firstly-recommended" plugin.
local fugitive = {
    "tpope/vim-fugitive",
}

-- Show signs for added, removed, and changed lines.
local gitsigns = {
    "lewis6991/gitsigns.nvim", config = true,
}

return {
    fugitive,
    gitsigns,
}
