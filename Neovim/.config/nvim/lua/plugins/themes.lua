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
local onedark = {
    "navarasu/onedark.nvim",
    names = {
        "onedark",
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
        "rose-pine",
    },
}

local function get_random_element(list)
    math.randomseed(os.time())
    -- Generate a random index within the range of the list size.
    local index = math.random(#list)
    return list[index]
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
