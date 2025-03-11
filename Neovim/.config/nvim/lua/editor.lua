-- # Appearance setting

-- Show line numbers on the leftmost side.
vim.opt.number = true
-- Make the line number relative to the line with the cursor in front of each line.
vim.opt.relativenumber = true
-- Highlight the text line of the cursor.
vim.opt.cursorline = true
-- Highlight the screen column of the cursor.
vim.opt.cursorcolumn = true
-- Highlight the screen column 80 for conventional code styles.
vim.opt.colorcolumn = "80"
-- Reveal and distinguish tab, trail space, nbsp, and break more legibly.
-- http://vi.stackexchange.com/a/430/5663
-- Because trail space is enough, I discard the eol marker.
vim.opt.list = true
vim.opt.listchars = { tab = "␉·", trail = "␠", nbsp = "¬" }
vim.opt.showbreak = "↪"
-- Enable 24-bit RGB color in the TUI, which is better than
-- the traditional 256 term colors.
vim.opt.termguicolors = true
-- Highlight briefly on yank.
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank()
    end,
    desc = "Highlight briefly on yank",
})
-- ## Tabline, defines how tabpages title looks like
-- For convenience of cross-projects development, show project names directly.
function MyTabLine()
    local tabline = ""
    for index = 1, vim.fn.tabpagenr("$") do
        -- Select the highlighting for the current tabpage.
        if index == vim.fn.tabpagenr() then
            tabline = tabline .. "%#TabLineSel#"
        else
            tabline = tabline .. "%#TabLine#"
        end

        local win_num = vim.fn.tabpagewinnr(index)
        local working_directory = vim.fn.getcwd(win_num, index)
        local project_name = vim.fn.fnamemodify(working_directory, ":t")
        tabline = tabline .. " " .. project_name .. " "
    end

    -- Set the end of the last tabpage.
    tabline = tabline .. "%#TabLineFill#%T"

    return tabline
end
vim.go.tabline = "%!v:lua.MyTabLine()"
-- The default option of wildmenu is full. It won't stop at the common string.
-- So use longest instead. `list` show all candidates after the common string.
-- Note: this option only works for cmdline!
vim.opt.wildmode = { "longest", "list" }
-- When complete in the insert mode, it always show menu and info, and match
-- the longest common string.
vim.opt.completeopt = { "menu", "menuone", "longest", "preview" }
-- Only the last window show a status line.
vim.opt.laststatus = 3
-- Enable spell checker in some filetypes.
vim.opt.spell = true
-- Adopt American English spell and avoid regarding cjk chars as spell error.
vim.opt.spelllang = { "en_us", "cjk" }

-- # Behavior setting

-- Set minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3
-- Avoid relying on mode lines because they are code-irrelevant.
vim.opt.modeline = false
-- Raise a dialog asking whether to save the current file(s) when you quit.
vim.opt.confirm = true
-- Ignore case in search patterns.
vim.opt.ignorecase = true
-- Briefly jump to the matched one when a bracket is inserted.
vim.opt.showmatch = true
-- Show the matching results for 0.1 seconds.
vim.opt.matchtime = 1
-- Override the ignorecase option if the search pattern contains upper case characters
vim.opt.smartcase = true
-- Substitute with g flag. Use \c when necessary.
vim.opt.gdefault = true
-- Fold by indent.
vim.opt.foldmethod = "indent"
-- Keep undofile so that you still can undo even after you close and open a file again.
vim.opt.undofile = true
-- Make split behaviour always consistent.
vim.opt.splitright = true
vim.opt.splitbelow = true
-- To avoid failing to find NeoVim module in virtual environment, figure out the system Python for NeoVim.
-- https://github.com/neovim/neovim/issues/1887#issuecomment-280653872
if vim.fn.exists("$VIRTUAL_ENV") == 1 then
    local python_path = vim.fn.substitute(
        vim.fn.system("which -a python3 | head -n2 | tail -n1"),
        "\n",
        "",
        "g"
    )
    vim.g.python3_host_prog = python_path
else
    local python_path =
        vim.fn.substitute(vim.fn.system("which python3"), "\n", "", "g")
    vim.g.python3_host_prog = python_path
end

-- ## Indentation

-- http://vimcasts.org/episodes/tabs-and-spaces/
-- Almost all code styles prefers four spaces instead of one tab.
-- So in Insert mode: use spaces in place of tab characters.
vim.opt.expandtab = true
-- Set four spaces that a <Tab> in the file counts for.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- Enables the experimental Lua module loader, maybe faster.
vim.loader.enable()

-- # Keymap enhancement

-- ## Modified keymaps

-- Set mapleader as space rather than comma, the later is used for search jump.
vim.g.mapleader = " "

-- ## Additional keymaps
--
-- Write forcibly as root in Command-line mode.
-- https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
vim.keymap.set(
    "c",
    "w!!",
    "w !sudo tee %",
    { desc = "Save with sudo privileges." }
)

vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Quick save." })
vim.keymap.set("n", "<leader>q", ":q<cr>", { desc = "Quick quit." })
vim.keymap.set(
    "n",
    "<leader> ",
    ":nohlsearch<cr>",
    { desc = "Quick no highlight." }
)
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set(
    "n",
    "<leader>p",
    '"+p',
    { desc = "Paste from system clipboard" }
)

vim.keymap.set(
    "n",
    "<leader>1",
    "1gt<cr>",
    { desc = "Jump to the first tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>2",
    "2gt<cr>",
    { desc = "Jump to the second tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>3",
    "3gt<cr>",
    { desc = "Jump to the third tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>4",
    "4gt<cr>",
    { desc = "Jump to the fourth tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>5",
    "5gt<cr>",
    { desc = "Jump to the fifth tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>6",
    "6gt<cr>",
    { desc = "Jump to the sixth tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>7",
    "7gt<cr>",
    { desc = "Jump to the seventh tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>8",
    "8gt<cr>",
    { desc = "Jump to the eighth tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>9",
    "9gt<cr>",
    { desc = "Jump to the ninth tabpage." }
)
vim.keymap.set(
    "n",
    "<leader>0",
    "10gt<cr>",
    { desc = "Jump to the tenth tabpage." }
)

-- Do not jump when hitting `*`.
-- https://github.com/neovim/neovim/discussions/24285#discussioncomment-6420615
local function map_star()
    vim.fn.setreg(
        "/",
        [[\V\<]] .. vim.fn.escape(vim.fn.expand("<cword>"), [[/\]]) .. [[\>]]
    )
    vim.fn.histadd("/", vim.fn.getreg("/"))
    vim.opt.hlsearch = true
end
vim.keymap.set("n", "*", map_star)

-- ## Additional commands

vim.api.nvim_create_user_command("RemoveTrailingWhitespaces", function()
    vim.cmd([[silent %s/\s\+$//e]])
end, {})

-- ## Windows management

vim.keymap.set(
    "n",
    "<leader>h",
    "<C-W>h",
    { desc = "Quick move from right to left between windows." }
)
vim.keymap.set(
    "n",
    "<leader>j",
    "<C-W>j",
    { desc = "Quick move from up to down between windows." }
)
vim.keymap.set(
    "n",
    "<leader>k",
    "<C-W>k",
    { desc = "Quick move from down to up between windows." }
)
vim.keymap.set(
    "n",
    "<leader>l",
    "<C-W>l",
    { desc = "Quick move from left to right between windows." }
)

vim.keymap.set(
    "n",
    "<leader>v",
    ":vsplit<cr>",
    { desc = "Quick split vertically." }
)
vim.keymap.set(
    "n",
    "<leader>s",
    ":split<cr>",
    { desc = "Quick split horizontally." }
)

-- # Others

-- Disable useless netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
