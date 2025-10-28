vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" })
vim.pack.add({ {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "master",
} })
vim.pack.add({ "https://github.com/vim-scripts/applescript.vim" })
vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })
vim.pack.add({ "https://github.com/williamboman/mason.nvim" })

-- Sort buffers alphabetically
require("fzf-lua").setup({ buffers = { sort_lastused = false } })

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

require("render-markdown").setup({
    completions = { lsp = { enabled = true } },
    code = { sign = false },
})

require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
        border = "rounded",
    },
})
