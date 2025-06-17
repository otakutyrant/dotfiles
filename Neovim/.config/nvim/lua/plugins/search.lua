-- A highly extendable fuzzy finder over lists.
local telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        -- An fzf extension for telescope, writen in C.
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
        -- Get fzf loaded and working with telescope.
        require("telescope").load_extension("fzf")
    end,
    -- The official recommended keymaps for telescope.
    keys = {
        {
            "<leader>ff",
            require("telescope.builtin").find_files,
            { desc = "🛠️ Telescope find files" },
        },
        {
            "<leader>fg",
            require("telescope.builtin").live_grep,
            { desc = "🛠️ Telescope live grep" },
        },
        {
            "<leader>fb",
            require("telescope.builtin").buffers,
            { desc = "🛠️ Telescope buffers" },
        },
        {
            "<leader>fh",
            require("telescope.builtin").help_tags,
            { desc = "🛠️ Telescope find help tags" },
        },
        {
            "<leader>fr",
            require("telescope.builtin").registers,
            { desc = "🛠️ Telescope registers" },
        },
    },
}
-- Highlight and number the result when you use f or F to search a char.
local fFHighlight = {
    "kevinhwang91/nvim-fFHighlight",
    opts = {},
    event = "VeryLazy",
}

return {
    telescope,
    fFHighlight,
}
