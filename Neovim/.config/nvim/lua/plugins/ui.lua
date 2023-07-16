local nvim_tree = {
    "nvim-tree/nvim-tree.lua",
    lazy = false, -- Replace netrw exactly when opening a directory.
    dependencies = "nvim-tree/nvim-web-devicons", -- For file icons.
    config = function()
        require("nvim-tree").setup({
            -- Use nvim_tree instead of netrw.
            hijack_netrw = true,
            -- Changes the tree root directory on `DirChanged` and refreshes the tree.
            sync_root_with_cwd = true,
            -- Show LSP and COC diagnostics in the signcolumn.
            diagnostics = { enable = true },
            view = { signcolumn = "auto", number = true, relativenumber = true },
            git = { ignore = false },
        })
    end,
}

local colorizer = {
    "NvChad/nvim-colorizer.lua",
}

local lualine = {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons", -- For file icons.
    config = function()
        require("lualine").setup({
            sections = {
                lualine_x = {
                    "%{get(g:, 'colors_name', 'default')}", -- colorscheme
                    "encoding",
                    "fileformat",
                    "filetype",
                },
            },
        })
    end,
}

local indentline = {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true,
        })
    end,
}

local fFHighlight = {
    "kevinhwang91/nvim-fFHighlight",
    config = function()
        require("fFHighlight").setup({})
    end,
}

local noice = {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        -- Used for proper rendering and multiple views.
        "MunifTanjim/nui.nvim",
        -- Used for highlighting the cmdline and lsp docs.
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("noice").setup({
            lsp = {
                -- Override markdown rendering so that cmp and other plugins use Treesitter.
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            -- Enabling some presets for easier configuration.
            presets = {
                -- Use a classic bottom cmdline for search.
                bottom_search = true,
                -- Position the cmdline and popupmenu together.
                command_palette = true,
                -- Long messages will be sent to a split.
                long_message_to_split = true,
                -- Enables an input dialog for inc-rename.nvim.
                inc_rename = false,
                -- Add a border to hover docs and signature help.
                lsp_doc_border = false,
            },
        })
    end,
}

local whichkey = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
}

-- Map F1 as mandate file manager.
vim.keymap.set(
    "n",
    "<F1>",
    ":NvimTreeToggle<CR>",
    { desc = "Toggle filetree." }
)

return {
    nvim_tree,
    colorizer,
    lualine,
    indentline,
    fFHighlight,
    noice,
    whichkey,
}
