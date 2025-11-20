local M = {}
function M.update_lspconfigs()
    local config = vim.fs.abspath(vim.g.lsp_config)
    local repo = vim.fs.abspath(vim.g.lsp_repo)
    local lsp = vim.fs.joinpath(repo, "lsp")
    local lines = {}

    vim.fn.system("git -C " .. repo .. " pull")
    for _, file in ipairs(vim.g.lsp_enable_list) do
        vim.fn.system("cp " .. vim.fs.joinpath(lsp, file .. ".lua ") .. config)
        table.insert(lines, (vim.v.shell_error == 0 and "✅ " or "❌ ") .. file)
    end
    local buf_opts = { buflisted = false, modifiable = false }
    local float_opts = { title = "LSP Config Sync" }
    M.create_popup(lines, buf_opts, float_opts)
end

-- Create a floating popup window with given text lines
function M.create_popup(lines, user_buf, user_float, user_win)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local buf_opts = vim.tbl_extend("keep", user_buf or {}, { bufhidden = "wipe" })
    for k, v in pairs(buf_opts) do vim.bo[buf][k] = v end

    local width = math.max(unpack(vim.tbl_map(string.len, lines))) + 2
    local height = #lines
    local float_opts = vim.tbl_extend("keep", user_float or {}, {
        relative = "editor",
        width = math.min(width, math.floor(vim.o.columns * 0.8)),
        height = math.min(height, math.floor(vim.o.lines * 0.8)),
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
    })

    local win_id = vim.api.nvim_open_win(buf, true, float_opts)
    local win_opts = vim.tbl_extend("keep", user_win or {},
        { number = false, relativenumber = false, cursorline = false, signcolumn = "no" })
    for k, v in pairs(win_opts) do vim.wo[win_id][k] = v end

    local opt = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set("n", "q", ":q<cr>", opt)
    vim.keymap.set("n", "<Esc>", ":q<cr>", opt)
end

return M
