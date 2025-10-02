return {
    {
        "mfussenegger/nvim-dap",
    },
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup("uv")
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        opts = {},
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
    },
}
