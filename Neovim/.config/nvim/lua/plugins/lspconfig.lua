-- lspconfig offers an unified way to use language servers and obtain features like diagnostics and completion.

local nvim_lspconfig = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
}

-- # Language Server setups
-- Here are setups for some language servers, and all of them are used in lspconfig.

-- Firstly, fetch lspconfig to add setups.
local lspconfig = require("lspconfig")

-- Lua
-- This setup make lua-language-server handles Neovim lua-related config and even plugins code.
-- It is copied from https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls,
-- without me understanding it fully. Note that I replaced `vim.loop` with `vim.uv` since the former is deprecated in Neovim 0.10
lspconfig.lua_ls.setup({
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (
                    vim.uv.fs_stat(path .. "/.luarc.json")
                    or vim.uv.fs_stat(path .. "/.luarc.jsonc")
                )
            then
                return
            end
        end

        client.config.settings.Lua =
            vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                    -- Tell the language server which version of Lua you"re using
                    -- (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        -- Solve the issue about undefined `vim.uv.fs_stat`
                        -- See https://github.com/folke/lazy.nvim/discussions/1349#discussioncomment-9122673
                        "${3rd}/luv/library",
                        -- "${3rd}/busted/library",
                    },
                    -- or pull in all of "runtimepath". NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                    -- library = vim.api.nvim_get_runtime_file("", true)
                },
            })
    end,
    settings = {
        Lua = {
            format = { enable = false }, -- disable formatter in favor of stylua
        },
    },
})

-- Python
lspconfig.ruff.setup({}) -- for linting and formatting
-- Use pyright only for type checking and other ls features.
lspconfig.pyright.setup({
    settings = {
        pyright = {
            disableOrganizeImports = true, -- Using Ruff's import organizer instead
        },
        python = {
            analysis = {
                ignore = { "*" }, -- Ignore all files for analysis to exclusively use Ruff for linting
            },
        },
    },
})

-- HTML & CSS
-- Neovim does not currently include built-in snippets.
-- These two language servers only provides completions when snippet support is enabled.
-- So enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
lspconfig.html.setup({ capabilities = capabilities })
lspconfig.cssls.setup({ capabilities = capabilities })
lspconfig.eslint.setup({})

-- TypeScript & JavaScript
-- Actually this is not a language server.
local typescript_tools = {
    "pmizio/typescript-tools.nvim",
    opts = {},
}

-- TODO: To exploit lsp fully, like vim.lsp.buf.declaration and vim.lsp.buf.definition
-- Use LspAttach autocommand to map some lsp-buf functions.

-- Nushell
lspconfig.nushell.setup({})

-- # Final

return {
    typescript_tools,
    nvim_lspconfig,
}
