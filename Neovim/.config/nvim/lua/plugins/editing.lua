local comment = {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
        require("Comment").setup({
            pre_hook = require(
                "ts_context_commentstring.integrations.comment_nvim"
            ).create_pre_hook(),
        })
    end,
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

local lightbulb = {
    "kosayoda/nvim-lightbulb",
}

return {
    comment,
    surround,
    lightbulb,
}
