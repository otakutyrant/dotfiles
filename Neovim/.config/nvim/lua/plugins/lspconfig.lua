-- lspconfig offers an unified way to use language servers and obtain features like diagnostics and completion.

local nvim_lspconfig = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
}

-- # Language Server setups
-- Here are setups for some language servers, and all of them are used in lspconfig.

-- Lua
-- This setup make lua-language-server handles Neovim lua-related config and even plugins code.
-- It is copied from https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls,
-- without me understanding it fully. Note that I replaced `vim.loop` with `vim.uv` since the former is deprecated in Neovim 0.10
vim.lsp.enable("lua_ls")
vim.lsp.config("lua_ls", {
    -- This on_init use lua-language-server for Neovim, and want to provide completions, analysis, and location handling for plugins on runtime path.
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
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                    -- Tell the language server how to find Lua modules same way as Neovim
                    path = { "lua/?.lua", "lua/?/init.lua" },
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library", -- fix undefined uv.fs_stat warning, see https://github.com/NvChad/NvChad/issues/2960
                    },
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
vim.lsp.enable("ruff")
vim.lsp.config("ruff", {})
-- basedpyright is better than pyright since it supports more features.
vim.lsp.enable("basedpyright")
vim.lsp.config("basedpyright", {
    root_marker = {
        "pyproject.toml",
        -- "setup.py", -- Sometimes misleading.
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },
    settings = {
        basedpyright = {
            disableOrganizeImports = true, -- Using Ruff's import organizer instead
        },
    },
    -- These capabilities and on_init is used to fix wrong positionEncoding
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_init = function(client)
        client.offset_encoding = "utf-8"
    end,
})

-- TODO: To exploit lsp fully, like vim.lsp.buf.declaration and vim.lsp.buf.definition
-- Use LspAttach autocommand to map some lsp-buf functions.

-- Nushell
vim.lsp.enable("nushell")
vim.lsp.config("nushell", {})

-- TOML
vim.lsp.enable("taplo")
vim.lsp.config("taplo", {})

-- HTML
--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("html", {
    capabilities = capabilities,
})
vim.lsp.enable("html")

-- TypeScript
-- Pure Lua and better replacement of the origin ts_ls.
local ts_ls = {
    "pmizio/typescript-tools.nvim",
    opts = {
        settings = {
            tsserver_file_preferences = {
                -- Enforce ts_ls use absolute path import.
                importModuleSpecifierPreference = "non-relative",
            },
        },
    },
}
-- # Final

return {
    nvim_lspconfig,
    ts_ls,
}
