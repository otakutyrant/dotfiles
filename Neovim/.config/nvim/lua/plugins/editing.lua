local comment = {
    "numToStr/Comment.nvim", config = true,
    event = { "BufReadPre", "BufNewFile" },
}

local surround = {
    "kylechui/nvim-surround", config = true,
    version = "*", -- Use for stability; omit to use `main` branch for the latest features.
    event = "VeryLazy",
}

return {
    comment,
    surround,
}
