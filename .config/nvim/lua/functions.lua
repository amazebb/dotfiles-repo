local M = {}

--- Update the LSP config settings
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
    local opts = {
        buf = { modifiable = false },
        float = { title = "LSP Config Sync" }
    }
    M.floating_window(lines, opts)
end

-- Create a floating popup window with given text lines
---@param input table|fun(...)
---@param user_opts? table
function M.floating_window(input, user_opts)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local opts = vim.tbl_extend("keep", user_opts or {}, {
        enable_quit = true,
        buf = { buflisted = false, bufhidden = "wipe" },
        float = {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            style = "minimal",
            border = "rounded",
        },
        win_opts = { number = false, relativenumber = false, cursorline = false, signcolumn = "no" }
    })

    if type(input) == "table" then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, input)
        width = math.min(math.max(unpack(vim.tbl_map(string.len, input))) + 2, width)
        height = math.min(#input, height)
    end
    for k, v in pairs(opts.buf) do vim.bo[buf][k] = v end

    local win = vim.api.nvim_open_win(buf, true, opts.float)
    for k, v in pairs(opts.win_opts) do vim.wo[win][k] = v end

    if type(input) == "function" then
        input(win, buf)
    end

    if opts.enable_quit then
        vim.keymap.set({ "n", "t" }, "q", function()
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

--- Launch nnn file picker
function M.nnn()
    M.floating_window(_setup_nnn)
end

--- Create a commit message window
function M.commit_msg_popup()
    M.floating_window(function(win, buf)
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_buf_call(buf, function()
            vim.fn.jobstart('zsh -c "git-wrapper commit -va"', {
                term = true,
            })
            vim.cmd("startinsert!")
        end)
    end, { enable_quit = false })
end

return M
