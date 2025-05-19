-- A file manager.
local neo_tree = {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false, -- neo-tree will lazily load itself
    ---@module "neo-tree"
    opts = {
        event_handlers = {
            {
                -- show numbers in neo-tree
                event = "neo_tree_buffer_enter",
                handler = function(_)
                    vim.cmd([[ setlocal number ]])
                    vim.cmd([[ setlocal relativenumber ]])
                end,
            },
        },
    },
    keys = {
        {
            "<F1>", -- this will overwrite its origin feature: neovim-help, but the later is useless anyway
            ":Neotree toggle<CR>",
            { desc = "🛠️ Toggle neo-tree." },
        },
    },
}

-- Enhance statusline and inlay hint status.
vim.api.nvim_set_hl(0, "LualineInlayOn", { fg = "#00ff00", bold = true }) -- Green and bold for "On"
vim.api.nvim_set_hl(0, "LualineInlayOff", { fg = "#ff0000", bold = true }) -- Red and bold for "Off"
local function inlay_hint_status()
    local status = vim.lsp.inlay_hint.is_enabled() and " Inlay"
        or " Inlay"
    local highlight = vim.lsp.inlay_hint.is_enabled() and "%#LualineInlayOn#"
        or "%#LualineInlayOff#"
    return highlight .. status
end

local lualine = {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = {
        sections = {
            lualine_y = {
                "%{get(g:, 'real_colors_name')}", -- show colorscheme
                inlay_hint_status,
            },
        },
    },
}

-- Make indents more obvious with vertical lines.
local indentline = {
    "lukas-reineke/indent-blankline.nvim",
    opts = {},
    main = "ibl", -- This is the official instruction.
}

-- Show rainbow parentheses.
local rainbow_delimiters = {
    "HiPhish/rainbow-delimiters.nvim",
}

-- Provide icons.
local nvim_web_devicons = {
    "nvim-tree/nvim-web-devicons",
    opts = {},
    lazy = true,
}

-- Show available keybindings in a popup as you type.
local whichkey = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "🛠️ Buffer Local Keymaps (which-key)",
        },
    },
}

-- Adds signs to the sign column to indicate added, changed, and deleted lines.
local gitsigns = {
    "lewis6991/gitsigns.nvim",
    opts = {},
}

local hardtime = {
   "m4xshen/hardtime.nvim",
   lazy = false,
   dependencies = { "MunifTanjim/nui.nvim" },
   opts = {},
}

return {
    neo_tree,
    lualine,
    indentline,
    rainbow_delimiters,
    nvim_web_devicons,
    whichkey,
    gitsigns,
    hardtime,
}
