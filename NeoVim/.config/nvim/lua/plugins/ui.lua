Nvim_tree = {
    "nvim-tree/nvim-tree.lua",
    lazy = false, -- Replace netrw exactly when opening a directory.
    dependencies = "nvim-tree/nvim-web-devicons", -- For file icons.
    config = function()
        require("nvim-tree").setup({
            -- Use nvim_tree instead of netrw.
            hijack_netrw = true,
            -- Changes the tree root directory on `DirChanged` and refreshes the tree.
            sync_root_with_cwd = true,
            -- Show LSP and COC diagnostics in the signcolumn.
            diagnostics = { enable = true },
            view = { signcolumn = "auto", number = true, relativenumber = true },
            git = { ignore = false },
        })
    end,
}

-- Map F1 as mandate file manager.
vim.keymap.set(
    "n",
    "<F1>",
    ":NvimTreeToggle<CR>",
    { desc = "Toggle filetree." }
)

return { Nvim_tree }
