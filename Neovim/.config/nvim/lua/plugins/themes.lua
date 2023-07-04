local tokyonight = {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    name = "tokyonight",
}

-- tokyonight
-- tokyonight-night
-- tokyonight-strom
-- tokyonight-day
-- tokyonight-moon

local monokai = {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    name = "monokai",
}

local function enable_colorscheme(theme)
    local wrapped_function = function()
        local theme_name = theme.name
        vim.cmd.colorscheme(theme_name)
    end
    return wrapped_function
end

local function getRandomElement(list)
    math.randomseed(os.time())
    -- Generate a random index within the range of the list size.
    local index = math.random(#list)
    return list[index]
end

local themes = { tokyonight, monokai }
local theme = getRandomElement(themes)
theme.config = enable_colorscheme(theme)

return themes
