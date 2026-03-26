-- AppleScript
vim.pack.add({ "https://github.com/vim-scripts/applescript.vim" })

-- fzf-lua
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("fzf-lua").setup({ buffers = { sort_lastused = false } })

-- Treesitter
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })

require("nvim-treesitter").install({
    "awk",
    "bash",
    "css",
    "diff",
    "fennel",
    "fortran",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "html",
    "java",
    "javascript",
    "julia",
    "latex",
    "matlab",
    "python",
    "sql",
    "tsx",
    "typescript",
    "yaml" }
)

-- Blink
vim.pack.add({
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

require("blink.cmp").setup({
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
})
