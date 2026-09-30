-- This file handles nvim-treesitter and related plugins.

local nvim_treesitter = {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter")
        -- Remember parsers already requested in this Neovim session so opening
        -- several buffers of the same filetype does not start duplicate installs.
        local installing = {}

        treesitter.setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- Install Tree-sitter parsers lazily by filetype instead of maintaining
        -- a fixed language list. This keeps a fresh system usable after opening
        -- a file for the first time, while existing parsers stay untouched.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function(event)
                local filetype = vim.bo[event.buf].filetype
                -- Neovim maps filetypes to Tree-sitter language names, e.g.
                -- `typescriptreact` can become `tsx` when registered elsewhere.
                local language = vim.treesitter.language.get_lang(filetype)
                if not language or installing[language] then
                    return
                end

                -- Parsers are shared objects found from `runtimepath`; if one
                -- already exists, nvim-treesitter has nothing to install.
                local parser_files = vim.api.nvim_get_runtime_file(
                    "parser/" .. language .. ".*",
                    true
                )
                if #parser_files > 0 then
                    return
                end

                -- Install the parser and its queries on demand. `:TSUpdate`
                -- still handles later updates for parsers installed this way.
                installing[language] = true
                treesitter.install({ language })
            end,
            desc = "Install missing Tree-sitter parsers on demand",
        })
    end,
}

local nvim_treesitter_context = {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
}

return {
    nvim_treesitter,
    nvim_treesitter_context,
}
