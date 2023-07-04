-- Lazy
require("os")

local chatgpt = {
    "jackMort/ChatGPT.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
    config = function()
        require("chatgpt").setup({
            -- Secret Management.
            -- https://github.com/jackMort/ChatGPT.nvim#secrets-management
            api_key_cmd = "cat "
                .. os.getenv("HOME")
                .. "/.config/nvim/chatgpt_api.txt",
        })
    end,
}

return {
    chatgpt,
}
