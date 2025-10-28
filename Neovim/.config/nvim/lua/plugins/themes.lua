-- This file contains multople colorschemes and a random mechanism to pick
-- one of them every time starting Neovim. The random mechanism is adapted
-- to Lazy.nvim.

local tokyonight = {
    "folke/tokyonight.nvim",
    names = {
        "tokyonight",
        "tokyonight-night",
        "tokyonight-strom",
        "tokyonight-day",
        "tokyonight-moon",
    },
}

local monokai = {
    "tanvirtin/monokai.nvim",
    names = {
        "monokai",
        "monokai_pro",
        "monokai_soda",
        "monokai_ristretto",
    },
}

-- A super theme supports plenty plugins and configurations.
local nord = {
    "shaunsingh/nord.nvim",
    names = {
        "nord",
    },
}

-- A super theme supports much plugins and configurations.
local everforest = {
    "sainnhe/everforest",
    names = {
        "everforest",
    },
}

-- Supports multiple styles. TODO: Convert styles to names.
-- Due to the PR stucks, use my fork instead at the moment.
-- https://github.com/navarasu/onedark.nvim/pull/178
local onedark = {
    "otakutyrant/onedark.nvim",
    branch = "multiple_colorschemes",
    names = {
        "onedark-dark",
        "onedark-darker",
        "onedark-cool",
        "onedark-deep",
        "onedark-dark",
        "onedark-warm",
        "onedark-warmer",
        "onedark-light",
    },
}

local gruvbox = {
    "ellisonleao/gruvbox.nvim",
    names = {
        "gruvbox",
    },
}

local sonokai = {
    "sainnhe/sonokai",
    names = {
        "sonokai",
    },
}

local rose_pine = {
    "rose-pine/neovim",
    names = {
        "rose-pine-dawn",
        "rose-pine-main",
        "rose-pine-moon",
    },
}

local catppuccin = {
    "catppuccin/nvim",
    names = {
        "catppuccin",
        "catppuccin-latte",
        "catppuccin-frappe",
        "catppuccin-macchiato",
        "catppuccin-mocha",
    },
}

local zenbones = {
    "mcchrish/zenbones.nvim",
    dependencies = {
        "rktjmp/lush.nvim",
    },
    names = {
        "zenwritten",
        "neobones",
        "vimbones",
        "rosebones",
        "forestbones",
        "nordbones",
        "tokyobones",
        "seoulbones",
        "duckbones",
        "zenburned",
        "kanagawabones",
    },
}

local alabaster = {
    "https://git.sr.ht/~p00f/alabaster.nvim",
    names = {
        "alabaster",
    },
}

local function get_random_element(list, weighted)
    --[[
    --If weighted set to true, the element of the list is a list presumably.
    --Then the length of elements is taken into account.
    --]]
    weighted = weighted or false
    if weighted then
        math.randomseed(os.time())
        local total_weights = 0
        for _, sub_list in pairs(list) do
            total_weights = total_weights + #sub_list.names
        end
        local flattened_index = math.random(total_weights)
        local weight = 0
        for index, sub_list in pairs(list) do
            weight = weight + #sub_list.names
            if weight >= flattened_index then
                return list[index]
            end
        end
    else
        math.randomseed(os.time())
        -- Generate a random index within the range of the list size.
        local index = math.random(#list)
        return list[index]
    end
end

local function enable_colorscheme(theme_name)
    local wrapped_function = function()
        vim.cmd.colorscheme(theme_name)
    end
    vim.g.real_colors_name = theme_name
    return wrapped_function
end

local themes = {
    tokyonight,
    monokai,
    nord,
    everforest,
    onedark,
    gruvbox,
    sonokai,
    rose_pine,
    catppuccin,
    zenbones,
    alabaster,
}

-- Make all theme plugins loaded early to set colorscheme thereafter.
for _, theme in pairs(themes) do
    theme.lazy = false
    theme.priority = 1000
end

local theme = get_random_element(themes, true)
local theme_name = get_random_element(theme.names)
theme.config = enable_colorscheme(theme_name)

-- Alabaster non-essential overlay (place this alongside your theme selection)
-- This overlay copies "non-essential" highlight colors from Alabaster
-- and reapplies them on top of any other colorscheme.

local NON_ESSENTIAL = {
    -- Vim syntax groups
    "Keyword",
    "Statement",
    "Conditional",
    "Repeat",
    "Operator",
    "Function",
    "Type",
    "Structure",
    "PreProc",
    "Special",
    "Identifier",
    -- Tree-sitter captures
    "@keyword",
    "@function",
    "@type",
    "@operator",
    "@field",
    "@property",
}

local function rgb_to_hex(color)
    if not color then
        return nil
    end
    return string.format("#%06x", color)
end

local function get_highlight(group)
    local ok, highlight =
        pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if not ok or not highlight then
        return { foreground_color = nil, background_color = nil }
    end
    return {
        foreground_color = highlight.fg and rgb_to_hex(highlight.fg) or nil,
        background_color = highlight.bg and rgb_to_hex(highlight.bg) or nil,
    }
end

local function apply_group_foreground_colors(map)
    for group, foreground_color in pairs(map) do
        if foreground_color then
            pcall(vim.api.nvim_set_hl, 0, group, { fg = foreground_color })
        end
    end
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local current_theme = vim.g.colors_name or ""

        -- Capture Alabaster's non-essential highlights
        local alabaster_map = {}
        do
            local ok = pcall(function()
                vim.cmd("colorscheme alabaster")
            end)
            if not ok then
                return
            end

            for _, group in ipairs(NON_ESSENTIAL) do
                local highlight = get_highlight(group)
                if highlight and highlight.foreground_color then
                    alabaster_map[group] = highlight.foreground_color
                end
            end
        end

        -- Reload the user's chosen theme
        local ok2 = pcall(function()
            vim.cmd("colorscheme " .. current_theme)
        end)
        if not ok2 then
            return
        end

        -- Apply Alabaster's colors over it
        apply_group_foreground_colors(alabaster_map)
    end,
})

return themes
