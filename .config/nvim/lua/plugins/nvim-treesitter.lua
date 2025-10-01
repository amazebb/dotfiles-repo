return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "master",
    build = ":TSUpdate",
    config = function()
        ---@diagnostic disable-next-line: missing-fields
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
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = { enable = true },
        })
    end,
}
