local tokyonight = {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
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
    lazy = false,
    priority = 1000,
    opts = {},
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
    lazy = false,
    priority = 1000,
    names = {
        "nord",
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
}
local theme = get_random_element(themes)
local theme_name = get_random_element(theme.names)
theme.config = enable_colorscheme(theme_name)

return themes
