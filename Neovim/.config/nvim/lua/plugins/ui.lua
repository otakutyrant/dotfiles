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
    end,
}

-- Map F1 as mandate file manager.
vim.keymap.set(
    "n",
    "<F1>",
    ":NvimTreeToggle<CR>",
    { desc = "Toggle filetree." }
)

-- Render color of a color code.
local colorizer = {
    "NvChad/nvim-colorizer.lua",
}

-- Enhance statusline.
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

-- Highlight and number the result when you use f or F to search a char.
local fFHighlight = {
    "kevinhwang91/nvim-fFHighlight",
    config = function()
        require("fFHighlight").setup({})
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
    fFHighlight,
    gitsigns,
}
