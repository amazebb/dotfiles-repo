return {
  {
    "luukvbaal/nnn.nvim",
    config = function() require("nnn").setup() end,
  },
  -- {
  -- 	"nvim-neo-tree/neo-tree.nvim",
  -- 	branch = "v3.x",
  -- 	dependencies = {
  -- 		"nvim-lua/plenary.nvim",
  -- 		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  -- 		"MunifTanjim/nui.nvim",
  -- 		-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
  -- 	},
  -- 	lazy = false, -- neo-tree will lazily load itself
  -- 	---@module "neo-tree"
  -- 	---@type neotree.Config?
  -- 	opts = {
  -- 		-- fill any relevant options here
  -- 		window = {
  -- 			mappings = {
  -- 				["e"] = function()
  -- 					vim.api.nvim_exec("Neotree focus filesystem left", true)
  -- 				end,
  -- 				desc = "Focus Filesystem",
  -- 				["b"] = function()
  -- 					vim.api.nvim_exec("Neotree focus buffers left", true)
  -- 				end,
  -- 				desc = "Focus buffers",
  -- 				["g"] = function()
  -- 					vim.api.nvim_exec("Neotree focus git_status left", true)
  -- 				end,
  -- 				desc = "Focus git status",
  -- 			},
  -- 		},
  -- 	},
  -- },
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
