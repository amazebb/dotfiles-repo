local M = {}

function M.pretty_json(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n") .. "\n"
    local result = vim.system({ "jq" }, { text = true, stdin = input }):wait()
    if result.code ~= 0 then
        error("pretty_json: Failed to pretty print JSON " .. result.stderr)
    end
    local new_lines = vim.split(result.stdout, "\n", { trimempty = true })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

---Use MacOS security to get password given service name
---@param service string
---@return string|nil
function M.get_password(service)
    local result = vim.system(
        { 'security', 'find-generic-password', '-s', service, '-w' },
        { text = true, timeout = 5000 }
    ):wait()

    if result.code ~= 0 then
        local msg = 'Failed to read "' .. service .. '" from keychain (code: ' .. result.code .. ')'
        vim.notify(msg, vim.log.levels.ERROR)
        error(msg)
    end
    return result.stdout and result.stdout:gsub('%s+$', '') or nil
end

--- Update the LSP config settings
function M.update_lspconfigs()
    local config = vim.fs.abspath(vim.g.lsp_config)
    local repo = vim.fs.abspath(vim.g.lsp_repo)
    local lsp = vim.fs.joinpath(repo, "lsp")
    local lines = {}

    vim.system({ "git", "-C", repo, "pull" }, { text = true }, vim.schedule_wrap(function(result)
        if vim.trim(result.stdout) == "Already up to date." then
            -- Copy all files when there has been a change
            for _, file in ipairs(vim.g.lsp_enable_list) do
                local ok, err = vim.uv.fs_copyfile(vim.fs.joinpath(lsp, file .. ".lua"),
                    vim.fs.joinpath(config, file .. ".lua"))
                table.insert(lines, (ok and "✅ " or "❌ " .. err .. " ") .. file)
            end
        else
            lines = { "No changes to nvim-lspconfig repository" }
        end
        local opts = {
            buf = { modifiable = false },
            float = { title = "LSP Config Sync" }
        }
        M.floating_window(lines, opts)
    end))
end

-- Create a floating popup window with given text lines and configurable options
---@param input table|fun(...)
---@param user_opts? table
function M.floating_window(input, user_opts)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local opts = vim.tbl_deep_extend("keep", user_opts or {}, {
        enable_quit = true,
        fun = nil,
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
    if type(opts.fun) == "function" then
        opts.fun(win, buf)
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
            local output = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

            local file = output[1]
            if file and vim.uv.fs_stat(file) ~= nil then
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
