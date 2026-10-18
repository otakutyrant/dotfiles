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

-- Route buffers to external formatters without encoding project style here.
-- Each formatter receives the file path and resolves configuration from the
-- project working tree when it supports project-local configuration.
local conform = {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
        formatters_by_ft = {
            html = { "prettier" },
            css = { "prettier" },
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "yamlfmt" },
            markdown = { "prettier" },
            python = { "ruff_format" },
            toml = { "taplo" },
            lua = { "stylua" },
            nix = { "nixfmt" },
        },
        format_on_save = {
            timeout_ms = 1000,
        },
    },
}

return {
    comment,
    surround,
    conform,
}
