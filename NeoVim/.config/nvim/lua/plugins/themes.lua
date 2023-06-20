return {
    {
        "tanvirtin/monokai.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
        config = function()
            -- Enable 24-bit RGB color in the TUI, which is better than the tranditional 256 term colors.
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("monokai")
        end,
    }
}
