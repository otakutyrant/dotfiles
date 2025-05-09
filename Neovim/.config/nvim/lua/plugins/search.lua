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
        -- File and text search in hidden files and directories
        --https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
        local telescope = require("telescope")
        local telescopeConfig = require("telescope.config")
        -- Clone the default Telescope configuration
        local vimgrep_arguments =
            { unpack(telescopeConfig.values.vimgrep_arguments) }
        -- I want to search in hidden/dot files.
        table.insert(vimgrep_arguments, "--hidden")
        -- I don't want to search in the `.git` directory.
        table.insert(vimgrep_arguments, "--glob")
        table.insert(vimgrep_arguments, "!**/.git/*")
        telescope.setup({
            defaults = {
                -- `hidden = true` is not supported in text grep commands.
                vimgrep_arguments = vimgrep_arguments,
            },
            pickers = {
                find_files = {
                    -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                    find_command = {
                        "rg",
                        "--files",
                        "--hidden",
                        "--glob",
                        "!**/.git/*",
                    },
                },
            },
        })
    end,
    -- The official recommended keymaps for telescope.
    keys = {
        { "<leader>ff", require("telescope.builtin").find_files, { desc = "Telescope find files"} },
        { "<leader>fg", require("telescope.builtin").live_grep, { desc = "Telescope live grep"} },
        { "<leader>fb", require("telescope.builtin").buffers, { desc = "Telescope buffers"} },
        { "<leader>fh", require("telescope.builtin").help_tags, { desc = "Telescope find help tags"}},
        { "<leader>fr", require("telescope.builtin").registers, { desc = "Telescope registers"} },
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
