local comment = {
    "numToStr/Comment.nvim",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
}

local surround = {
    "kylechui/nvim-surround",
    config = true,
    version = "*", -- Use for stability; omit to use `main` branch for the latest features.
    event = "VeryLazy",
}

local autotag = {
    "windwp/nvim-ts-autotag",
    config = true,
}

-- formatter
local conform = {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
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
                python = { "ruff_organize_imports" },
                -- python = { 'ruff_format', 'ruff_fix' },
                toml = { "taplo" },
                lua = { "stylua" },
            },
            format_on_save = {
                -- These options will be passed to conform.format()
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        })
        vim.keymap.set("n", "<leader>tw", function()
            require("conform").format({ formatters = { "trim_whitespace" } })
        end, { desc = "Trim trailing whitespace" })
    end,
}

return {
    comment,
    surround,
    autotag,
    conform,
}
