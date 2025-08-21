return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    config = function()
        if vim.env.TERM == "xterm-kitty" then
            vim.cmd("colorscheme github_dark")
        end
    end,
}
