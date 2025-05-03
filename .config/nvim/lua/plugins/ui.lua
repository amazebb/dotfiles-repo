return {
  {
    "luukvbaal/nnn.nvim",
    config = function() require("nnn").setup() end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "solarized_dark",
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
        tabline = {
          lualine_a = {
            {
              "buffers",
              show_filename_only = true,
              show_modified_status = true,
              icons_enabled = false,
              separator = "|",
              symbols = { alternate_file = "", directory = "" },
            },
          },
        },
      })
    end,
  },
}
