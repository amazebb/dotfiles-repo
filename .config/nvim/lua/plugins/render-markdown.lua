_G.latex_enabled = true

return {
    'MeanderingProgrammer/render-markdown.nvim',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        completions = { lsp = { enabled = true } },
        code = { sign = false },
        latex = {
            enabled = true,
            converter = 'latex2text',
            highlight = 'RenderMarkdownMath',
            position = 'above',
            top_pad = 0,
            bottom_pad = 0,
        },
    },
    file_types = { 'markdown', 'quarto', 'codecompanion' },
}
