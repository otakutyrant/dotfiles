-- Keep Git repository context visible while browsing. githead provides the
-- branch, upstream divergence, and working-tree counts that Joshuto lacked.
require("githead"):setup({
    -- Keep the header short while showing the useful repository summary.
    order = {
        "branch",
        "behind_ahead_remote",
        "staged",
        "unstaged",
        "untracked",
    },
    show_numbers = true,
    show_branch = true,
    show_behind_ahead_remote = true,
    show_staged = true,
    show_unstaged = true,
    show_untracked = true,
    branch_symbol = " ",
    branch_prefix = "",
    branch_borders = "()",
    ahead_remote_symbol = "⇡",
    behind_remote_symbol = "⇣",
    staged_symbol = "+",
    unstaged_symbol = "!",
    untracked_symbol = "?",
})

-- Show Git changes on files and directories, including repositories viewed
-- from their parent directory.
require("git"):setup({
    order = 1500,
})

-- Summarize repository directories while browsing their parent directory.
require("git-repo"):setup()
