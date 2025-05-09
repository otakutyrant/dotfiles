local nvim_cmp = {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        -- For Luasnip users.
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    opts = function(_, opts)
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        opts.snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        }

        opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
        })

        opts.sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
        }, {
            { name = "path" },
            { name = "buffer" },
        })

        return opts
    end,
}

return {
    nvim_cmp,
}
