-- A file manager.
local neo_tree = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    keys = {
        {
            "<F1>", -- this will overwrite its origin feature: neovim-help, but the later is useless anyway
            ":Neotree toggle<CR>",
            { desc = "Toggle neo-tree." },
        },
    },
}

-- Render color of a color code.
local colorizer = {
    "NvChad/nvim-colorizer.lua",
    opts = {},
    event = "VeryLazy",
}

-- Enhance statusline.
local lualine = {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
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
    },
}

-- Make indents more obvious with vertical lines.
local indentline = {
    "lukas-reineke/indent-blankline.nvim",
    opts = {},
    -- This is the official instruction, and I do not know what their point are.
    main = "ibl",
}

local rainbow_delimiters = {
    "HiPhish/rainbow-delimiters.nvim",
}

-- Provide icons.
local nvim_web_devicons = {
    "nvim-tree/nvim-web-devicons",
    opts = {},
    lazy = true,
}

return {
    neo_tree,
    colorizer,
    lualine,
    indentline,
    rainbow_delimiters,
    nvim_web_devicons,
}
