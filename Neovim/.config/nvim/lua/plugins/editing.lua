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
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            python = {
                "ruff_fix", -- To fix auto-fixable lint errors.
                "ruff_format", -- To run the Ruff formatter.
                "ruff_organize_imports", -- To organize the imports.
            }, -- Although ruff is a ls, the official suggests using these formatters
            toml = {}, -- TOMP formatter is provided by taplo ls.
            lua = { "stylua" }, -- lua_ls' primitive formatter is disabled
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 1000,
            lsp_format = "fallback", -- use vim.lsp.buf.format() when no formatter available.
        },
    },
}

return {
    comment,
    surround,
    conform,
}
