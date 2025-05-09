local comment = {
    "numToStr/Comment.nvim",
    opts = {},
    event = "VeryLazy",
}

local surround = {
    "kylechui/nvim-surround",
    opts = {},
    version = "*", -- Use for stability; omit to use `main` branch for the latest features.
    event = "VeryLazy",
}

local autotag = {
    "windwp/nvim-ts-autotag", -- It is lazy enough.
    opts = {},
}

-- formatter
local conform = {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            html = { "prettier" },
            css = { "prettier" },
            json = { "prettier" },
            -- deno = { 'prettier' },
            yaml = { "prettier" },
            markdown = { "prettier" },
            typescript = { "prettier" },
            -- ocaml = { 'ocamlformat' },
            -- nix = { 'nixpkgs-fmt' },
            python = {}, -- Python formatter is provided by ruff ls.
            toml = { "taplo" },
            lua = { "stylua" }, -- and lua_ls's formatter is disabled elsewhere
        },
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_format = "fallback",
        },
    },
    keys = {
        {
            "<leader>rtw",
            function()
                require("conform").format({ formatters = { "trim_whitespace" } })
            end,
            desc = "Trim trailing whitespace",
        },
    },
}

return {
    comment,
    surround,
    autotag,
    conform,
}
