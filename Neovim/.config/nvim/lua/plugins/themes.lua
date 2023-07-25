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

local function get_random_element(list, weighted)
    --[[
    --If weighted set to true, the element of the list is a list presumably.
    --Then the length of elements is taken into account.
    --]]
    weighted = weighted or false
    if weighted then
        local total_weights = 0
        for _, sub_list in pairs(list) do
            total_weights = total_weights + #sub_list
        end
        local flattened_index = math.random(total_weights)
        local weight = 0
        for index, sub_list in pairs(list) do
            weight = weight + #sub_list
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
}

-- Make all theme plugins loaded early to set colorscheme thereafter.
for _, theme in pairs(themes) do
    theme.lazy = false
    theme.priority = 1000
end

local theme = get_random_element(themes)
local theme_name = get_random_element(theme.names)
theme.config = enable_colorscheme(theme_name)

return themes
