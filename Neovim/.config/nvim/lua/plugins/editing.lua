local comment = {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
}

local surround = {
    "kylechui/nvim-surround",
    dependendcies = {
        "nvim-treesitter",
        "nvim-treesitter-textobjects",
    },
    version = "*", -- Use for stability; omit to use `main` branch for the latest features.
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({})
    end,
}

return {
    comment,
    surround,
}
