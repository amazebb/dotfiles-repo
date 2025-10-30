vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })
vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons" })
vim.pack.add({ {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "master",
} })
vim.pack.add({ "https://github.com/vim-scripts/applescript.vim" })
vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })
vim.pack.add({
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})

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

require("blink.cmp").setup({
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true },
    keymap = {
        preset = "default",
        ["<C-space>"] = {},
        ["<C-p>"] = {},
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
        ["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-n>"] = { "select_and_accept" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_down", "fallback" },
        ["<C-f>"] = { "scroll_documentation_up", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
        -- ["<C-e>"] = { "hide" },
    },

    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "normal",
    },

    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },

    cmdline = {
        keymap = {
            preset = "inherit",
            ["<CR>"] = { "accept_and_enter", "fallback" },
        },
    },

    sources = { default = { "lsp" } },
})
