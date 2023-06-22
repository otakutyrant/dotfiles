-- A highly extendable fuzzy finder over lists.
telescope = {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim" }, -- Library API.
        -- An fzf extension for telescope, writen in C.
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
        -- Get fzf loaded and working with telescope.
        require("telescope").load_extension("fzf")
        -- The official recommended keymaps for telescope.
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
        -- File and text search in hidden files and directories
        --https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
        local telescopeConfig = require("telescope.config")
        -- Clone the default Telescope configuration
        local vimgrep_arguments =
            { unpack(telescopeConfig.values.vimgrep_arguments) }
        -- I want to search in hidden/dot files.
        table.insert(vimgrep_arguments, "--hidden")
        -- I don't want to search in the `.git` directory.
        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!**/.git/*")
    end,
}

return {
    telescope,
}
