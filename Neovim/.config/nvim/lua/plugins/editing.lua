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
    "windwp/nvim-ts-autotag", config = true,
}

-- formatter
local conform = {
    'stevearc/conform.nvim',
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                html = { 'prettier' },
                css = { 'prettier' },
                json = { 'prettier' },
                -- deno = { 'prettier' },
                yaml = { 'prettier' },
                markdown = { 'prettier' },
                typescript = { 'prettier' },
                -- ocaml = { 'ocamlformat' },
                -- nix = { 'nixpkgs-fmt' },
                -- python = { 'ruff_format', 'ruff_organaize_imports', 'ruff_fix' },
            },
            format_on_save = {
                -- These options will be passed to conform.format()
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        })
    end,
}

return {
    comment,
    surround,
    autotag,
    conform,
}
