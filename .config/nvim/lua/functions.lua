local M = {}
function M.update_lspconfigs()
    local pwd = vim.fn.getcwd()
    local config = vim.fs.abspath(vim.g.lsp_config)
    local repo = vim.fs.abspath(vim.g.lsp_repo)
    local lsp = vim.fs.joinpath(repo, "lsp")

    local results = {}
    local lines = {}
    local highlights = {}

    vim.fn.execute("cd " .. repo)
    vim.fn.system("git pull")
    for i, file in ipairs(vim.g.lsp_enable_list) do
        local result = vim.fn.system("cp " .. vim.fs.joinpath(lsp, file .. ".lua") .. " " .. config)
        results[i] = {
            file = file,
            success = vim.v.shell_error == 0, -- 0 means success
            error = vim.v.shell_error ~= 0 and result or nil,
        }
        table.insert(lines, results[i].success and "✔ " .. file or "✘ " .. file)
        table.insert(highlights, results[i].success and "SuccessMsg" or "ErrorMsg")
    end
    vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#FF0000" })
    vim.api.nvim_set_hl(0, "SuccessMsg", { fg = "#00FF00" })
    M.create_popup(lines, highlights)
    vim.fn.execute("cd " .. pwd)
end

-- Create a floating popup window with given text lines
function M.create_popup(lines, highlights)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local ns_id = vim.api.nvim_create_namespace("popup_highlights") -- Create namespace
    if highlights then
        for i, hl in ipairs(highlights) do
            -- TODO we are only coloring the first column because we know atm
            -- that we are using a single tick/x to highlight success/error
            -- Make this better for improved handling of highlights
            vim.hl.range(buf, ns_id, hl, { i - 1, 0 }, { i - 1, 1 }, {})
        end
    end
    vim.bo[buf].filetype = "text"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false

    local width = math.max(unpack(vim.tbl_map(string.len, lines))) + 2
    local height = #lines
    local win_id = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.min(width, math.floor(vim.o.columns * 0.8)),
        height = math.min(height, math.floor(vim.o.lines * 0.8)),
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
        title = "LSP Config Sync",
    })
    vim.wo[win_id].number = false
    vim.wo[win_id].relativenumber = false
    vim.wo[win_id].cursorline = false
    vim.wo[win_id].signcolumn = "no"

    local opt = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set("n", "q", ":q<cr>", opt)
    vim.keymap.set("n", "<Esc>", ":q<cr>", opt)
end

return M
