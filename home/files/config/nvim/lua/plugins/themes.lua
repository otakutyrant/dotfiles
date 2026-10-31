-- Keep Alabaster as the sole theme so startup appearance stays consistent.
return {
    {
        "https://git.sr.ht/~p00f/alabaster.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.real_colors_name = "alabaster"
            vim.cmd.colorscheme("alabaster")

            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    -- Match strings to keep comments easy to distinguish.
                    local highlight = vim.api.nvim_get_hl(
                        0,
                        { name = "String", link = false }
                    )
                    if highlight.fg then
                        vim.api.nvim_set_hl(0, "Comment", { fg = highlight.fg })
                    end
                end,
            })
        end,
    },
}
