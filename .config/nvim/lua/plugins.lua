-- AppleScript
vim.pack.add({ "https://github.com/vim-scripts/applescript.vim" })

-- fzf-lua
vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
require("fzf-lua").setup({ buffers = { sort_lastused = false } })

-- Treesitter
vim.pack.add({ {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "master",
} })

---@diagnostic disable: missing-fields
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "awk",
        "bash",
        "c",
        "fortran",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
        "typescript",
        "tsx",
        "python",
        "html",
        "css",
        "java",
        "javascript",
        "julia",
        "query",
        "sql",
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = { enable = true },
})
---@diagnostic enable: missing-fields

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
