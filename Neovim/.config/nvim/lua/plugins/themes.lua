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

local function getRandomElement(list)
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
}
local theme = getRandomElement(themes)
local theme_name = getRandomElement(theme.names)
theme.config = enable_colorscheme(theme_name)

return themes
