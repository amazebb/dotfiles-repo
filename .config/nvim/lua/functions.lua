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
    local buf_opts = { modifiable = false }
    local float_opts = { title = "LSP Config Sync" }
    M.create_popup(lines, buf_opts, float_opts)
end

-- Create a floating popup window with given text lines
---@param input table|fun(...)
---@param user_buf? table
---@param user_float? table
---@param user_win? table
function M.create_popup(input, user_buf, user_float, user_win)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    if type(input) == "table" then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
        width = math.min(math.max(unpack(vim.tbl_map(string.len, input))) + 2, width)
        height = math.min(#input, height)
    end
    local buf_opts = vim.tbl_extend("keep", user_buf or {}, { buflisted = false, bufhidden = "wipe" })
    for k, v in pairs(buf_opts) do vim.bo[buf][k] = v end

    local float_opts = vim.tbl_extend("keep", user_float or {}, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
    })

    local win = vim.api.nvim_open_win(buf, true, float_opts)
    local win_opts = vim.tbl_extend("keep", user_win or {},
        { number = false, relativenumber = false, cursorline = false, signcolumn = "no" })
    for k, v in pairs(win_opts) do vim.wo[win][k] = v end


    if type(input) == "function" then
        input(win, buf)
    end

    -- Keymaps to close window and buffer with ESC or q
    for _, key in ipairs({ "<Esc>", "q" }) do
        vim.keymap.set({ "n", "t" }, key, function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = 0, silent = true })
    end
end

local function _setup_nnn(win, buf)
    -- Start zsh terminal, run script, focus, and enter insert mode
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_buf_call(buf, function()
        vim.fn.jobstart('zsh -c "nnn -G -p -" ', {
            term = true,
        })
        vim.cmd("startinsert!")
    end)

    -- Open selected file as echoed by the "-p -" option in new buffer when nnn exits
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            ---@diagnostic disable: param-type-mismatch
            local output = vim.fn.getbufline(buf, 1, "$")
            ---@diagnostic enable: param-type-mismatch

            local file = output[1]
            if file and vim.fn.filereadable(file) == 1 then
                vim.api.nvim_win_close(win, true)
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
                vim.cmd("edit " .. vim.fn.fnameescape(file))
                vim.cmd("doautocmd BufRead")
            end
        end,
    })
end

function M.nnn()
    M.create_popup(_setup_nnn)
end

return M
