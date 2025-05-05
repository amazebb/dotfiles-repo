return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "html", "javascript", "latex", "lua", "markdown", "markdown_inline", "python", "sql", "vim", "vimdoc", "yaml" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    config = true,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    config = function()
      require('render-markdown').setup({
        completions = { lsp = { enabled = true } },
      })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {}
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "olimorris/codecompanion.nvim",
    config = true,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  }
}
