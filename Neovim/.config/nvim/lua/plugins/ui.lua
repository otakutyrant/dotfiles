-- A file manager.
local neo_tree = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        { "3rd/image.nvim", opts = {} }, -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
        vim.keymap.set(
            "n",
            "<F2>",
            ":Neotree toggle<CR>",
            { desc = "Toggle neo-tree." }
        ),
    },
}

-- Render color of a color code.
local colorizer = {
    "NvChad/nvim-colorizer.lua",
    config = true,
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
    config = true,
    -- This is the official instruction, and I do not know what their point are.
    main = "ibl",
}

local rainbow_delimiters = {
    "HiPhish/rainbow-delimiters.nvim",
}

return {
    neo_tree,
    colorizer,
    lualine,
    indentline,
    rainbow_delimiters,
}
