-- lspconfig offers a unified way to use language servers and obtain features like diagnostics and complementation.

local lua_ls_setup = {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- Configuration settings for the nvim-lspconfig plugin
local nvim_lspconfig = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lspconfig = require("lspconfig")
        lspconfig.pyright.setup({})
        lspconfig.lua_ls.setup(lua_ls_setup)
        lspconfig.bashls.setup({})
    end,
}

return {
    nvim_lspconfig,
}
