local avante = {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"!
    opts = { provider = "gemini" },
    build = "make",
    dependencies = {
        "stevearc/dressing.nvim",
    },
}

return {
    avante,
}
