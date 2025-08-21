return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        options = {
            theme = "github_dark",
            component_separators = "|",
            section_separators = { left = "", right = "" },
        },

        sections = {
            lualine_c = {
                {
                    function()
                        local excluded = { "codecompanion" }
                        if vim.tbl_contains(excluded, vim.bo.filetype) then
                            return ""
                        end
                        return vim.fn.expand("%:~")
                    end,
                },
            },
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
    },
}
