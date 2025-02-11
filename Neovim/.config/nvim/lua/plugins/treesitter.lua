-- This file handles nvim-treesitter and related plugins.
-- The plugin nvim-treesitter use treesitter to add features to NeoVim or enhance default features, like highlight.

--- TODO: understand and refine it, then add it in the disable of highlight of nvim-treesitter.
local function disable_highlight_for_nvim_treesitter(lang, bufnr)
    if lang == "html" and vim.api.nvim_buf_line_count(bufnr) > 500 then
        return true
    end
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 3, false)) do
        if #line > 500 then
            return true
        end
    end
    return false
end

local nvim_treesitter = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    -- Automatically update all parsers when the plugin is installed or updated.
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            -- Install all parsers.
            ensure_installed = "all",
            highlight = { enable = true },
        })
    end,
}

-- Show context the context of the currently visible buffer contents when you scroll.
local nvim_treesitter_context = {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
}

local rainbow_delimiters = {
    "HiPhish/rainbow-delimiters.nvim",
}

--- TODO: understand and refine it, then decide whether to add it in the disable of highlight of nvim-treesitter.
local nvim_treesitter_textobjects = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-treesitter.configs").setup({
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        -- You can use the capture groups defined in textobjects.scm
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        -- You can optionally set descriptions to the mappings (used in the desc parameter of
                        -- nvim_buf_set_keymap) which plugins like which-key display
                        ["ic"] = {
                            query = "@class.inner",
                            desc = "Select inner part of a class region",
                        },
                        -- You can also use captures from other query groups like `locals.scm`
                        ["as"] = {
                            query = "@scope",
                            query_group = "locals",
                            desc = "Select language scope",
                        },
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]m"] = "@function.outer",
                        ["]c"] = "@class.outer",
                    },
                    goto_next_end = {
                        ["]M"] = "@function.outer",
                        ["]C"] = "@class.outer",
                    },
                    goto_previous_start = {
                        ["[m"] = "@function.outer",
                        ["[c"] = "@class.outer",
                    },
                    goto_previous_end = {
                        ["[M"] = "@function.outer",
                        ["[C"] = "@class.outer",
                    },
                },
            },
        })
    end,
}

return {
    nvim_treesitter,
    nvim_treesitter_context,
    rainbow_delimiters,
}
