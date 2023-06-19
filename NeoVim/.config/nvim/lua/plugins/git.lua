return {
    {
        "lewis6991/gitsigns.nvim", -- Show signs for added, removed, and changed lines
        config = function()
            require("gitsigns").setup({})
        end
    }
}
