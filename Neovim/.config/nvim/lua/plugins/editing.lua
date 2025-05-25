-- Advanded comment support
local comment = {
    "numToStr/Comment.nvim",
    opts = {},
    event = "VeryLazy",
}

-- Enhance pairs editing.
local surround = {
    "kylechui/nvim-surround",
    opts = {},
    version = "*", -- Use for stability; omit to use `main` branch for the latest features.
    event = "VeryLazy",
}

-- formatter
local conform = {
    "stevearc/conform.nvim",
    event = "BufWritePost",
    opts = {
        formatters_by_ft = {
            -- TODO: replace them with language servers if the later is better.
            html = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },

            python = {}, -- Python formatter is provided by ruff ls.
            toml = {}, -- TOMP formatter is provided by taplo ls.
            lua = { "stylua" }, -- lua_ls' primitive formatter is disabled
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback", -- use vim.lsp.buf.format() when no formatter available.
        },
    },
}

return {
    comment,
    surround,
    conform,
}
