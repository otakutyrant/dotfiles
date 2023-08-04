-- A file manager.
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
        -- Map F1 as mandate file manager.
        vim.keymap.set(
            "n",
            "<F1>",
            ":NvimTreeToggle<CR>",
            { desc = "Toggle filetree." }
        )
    end,
}

-- Render color of a color code.
local colorizer = {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
}

-- Enhance statusline.
local lualine = {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons", -- For file icons.
    config = function()
        require("lualine").setup({
            sections = {
                lualine_a = {
                    "filename",
                },
                lualine_b = {
                    "branch",
                    "diff",
                    "diagnostics",
                },
                lualine_c = {},
                lualine_x = {},
                lualine_y = {
                    "%{get(g:, 'real_colors_name')}", -- colorscheme
                    "encoding",
                    "fileformat",
                    "filetype",
                },
                lualine_z = {
                    "location",
                },
            },
        })
    end,
}

-- Make indents more obvious with vertical lines.
local indentline = {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("indent_blankline").setup({
            show_current_context = true,
            show_current_context_start = true,
        })
    end,
}

-- Show signs for added, removed, and changed lines.
local gitsigns = {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({})
    end,
}

return {
    nvim_tree,
    colorizer,
    lualine,
    indentline,
    gitsigns,
}
