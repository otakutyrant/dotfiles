local avante = {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"!
    opts = {
        -- provider = "gemini",
        provider = "openrouter",
        providers = {
            openrouter = {
                __inherited_from = "openai",
                endpoint = "https://openrouter.ai/api/v1",
                api_key_name = "OPENROUTER_API_KEY",
                model = "x-ai/grok-code-fast-1",
            },
        },
    },
    build = "make",
    dependencies = {
        "stevearc/dressing.nvim",
    },
}

return {
    avante,
}
