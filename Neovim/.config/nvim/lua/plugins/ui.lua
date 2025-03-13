-- A file manager.
local nvim_tree = {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons", -- For file icons.
    config = function()
        require("nvim-tree").setup({
            -- Changes the tree root directory on `DirChanged` and refreshes the tree.
            sync_root_with_cwd = true,
            -- Show LSP and COC diagnostics in the signcolumn.
            diagnostics = { enable = true },
            view = { signcolumn = "auto", number = true, relativenumber = true, },
            renderer = { icons = { show = { folder_arrow = false, }, }, },
        })
        -- Map F1 as mandate file manager.
        vim.keymap.set(
            "n",
            "<F1>",
            ":NvimTreeToggle<CR>",
            { desc = "Toggle nvim-tree." }
        )
    end,
}

-- Render color of a color code.
local colorizer = {
    "NvChad/nvim-colorizer.lua", config = true,
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
    "lukas-reineke/indent-blankline.nvim", config = true,
    -- This is the official instruction, and I do not know what their point are.
    main = "ibl",
}

local rainbow_delimiters = {
    "HiPhish/rainbow-delimiters.nvim",
}

return {
    nvim_tree,
    colorizer,
    lualine,
    indentline,
    rainbow_delimiters,
}
