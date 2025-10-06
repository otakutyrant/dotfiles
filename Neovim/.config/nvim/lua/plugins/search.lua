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
            function() require("telescope.builtin").find_files() end,
            { desc = "🛠️ Telescope find files" },
        },
        {
            "<leader>fg",
            function() require("telescope.builtin").live_grep() end,
            { desc = "🛠️ Telescope live grep" },
        },
        {
            "<leader>fb",
            function() require("telescope.builtin").buffers() end,
            { desc = "🛠️ Telescope buffers" },
        },
        {
            "<leader>fh",
            function() require("telescope.builtin").help_tags() end,
            { desc = "🛠️ Telescope find help tags" },
        },
        {
            "<leader>fr",
            function() require("telescope.builtin").registers() end,
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
