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
vim.opt.colorcolumn = '80'
-- Reveal and distinguish tab, trail space and nbsp more legibly.
-- http://vi.stackexchange.com/a/430/5663
-- Because trail space is enough, I discard the eol marker.
vim.opt.list = true
vim.opt.listchars = { tab = "␉·", trail = "␠", nbsp = "¬", }

-- ## Spell

-- Enable spell checker in some filetypes.
local spell_group = vim.api.nvim_create_augroup('spell_group', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
    pattern = { "gitcommit", "text", "markdown" },
    group = spell_group,
    callback = function()
        vim.opt_local.spell = true
    end
})
vim.api.nvim_create_autocmd('FileType', {
    pattern = { "gitcommit" },
    group = spell_group,
    callback = function()
        vim.opt_local.spellcapcheck = ""
    end
})
-- Adopt American English spell and avoid regarding cjk chars as spell error.
vim.opt.spelllang = { "en_us", "cjk", }

-- # Behavior setting

-- Set minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 3
-- Avoid relying on mode lines because they are code-irrelevant.
vim.opt.modeline = false
-- Raise a dialog asking whether to save the current file(s) when you quit.
vim.opt.confirm = true
-- Ignore case in search patterns.
vim.opt.ignorecase = true
-- Briefly jump to the matched one when a bracket is interted.
vim.opt.showmatch = true
-- Show the matching peron for 0.1 seconds.
vim.opt.matchtime = 1
-- Override the ignorecase option if the search pattern contains upper case characters
vim.opt.smartcase = true
-- To avoid failing to find NeoVim module in virtual environment, figure out the system Python for NeoVim.
-- https://github.com/neovim/neovim/issues/1887#issuecomment-280653872
if vim.fn.exists("$VIRTUAL_ENV") == 1 then
    local python_path = vim.fn.substitute(vim.fn.system("which -a python3 | head -n2 | tail -n1"), "\n", "", "g")
    vim.g.python3_host_prog = python_path
else
    local python_path = vim.fn.substitute(vim.fn.system("which python3"), "\n", "", "g")
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

-- # Keymap enhancement

-- ## Modified keymaps

vim.g.mapleader = ' '
-- ## Additional keymaps
-- Write forcibly as root in Command-line mode.
-- https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
vim.keymap.set('c', 'w!!', 'w !sudo tee %', { desc = 'Save with sudo privileges.' })
