local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("CmdlineEnter", {
    callback = function()
        vim.o.cmdheight = 1
    end,
})

autocmd("CmdlineLeave", {
    callback = function()
        vim.o.cmdheight = 0
    end,
})

autocmd("BufDelete", {
    pattern = "*",
    desc = "Stop LSP client if not attached to any buffers",
    callback = function(args)
        local buf = args.buf
        local clients = vim.lsp.get_clients({ bufnr = buf })
        if #clients == 0 then
            return
        end
        for _, client in pairs(clients) do
            local has_buffers = false
            for _, other_buf in pairs(vim.api.nvim_list_bufs()) do
                if other_buf ~= buf and vim.api.nvim_buf_is_loaded(other_buf) then
                    if vim.lsp.buf_is_attached(other_buf, client.id) then
                        has_buffers = true
                        break
                    end
                end
            end
            if not has_buffers then
                client:stop(true)
            end
        end
    end,
})

autocmd("LspAttach", {
    desc = "Enable LSP completion and auto-formatting on buffer write",
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then return end

        if client:supports_method("textDocument/formatting") then
            autocmd("BufWritePre", {
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end
    end,
})

-- Toggle basedpyright warnings function
local function toggle_unknown_types(value)
    local client = vim.lsp.get_clients({ name = "basedpyright" })[1]
    if not client then
        print("basedpyright not running")
        return
    end

    -- Toggle settings
    local settings = client.config.settings
    if settings ~= nil then
        settings.basedpyright.analysis.typeCheckingMode = value == ""
            and (settings.basedpyright.analysis.typeCheckingMode == "standard" and "recommended" or "standard")
            or value
    end

    -- Update LSP client
    client:notify("workspace/didChangeConfiguration", { settings = settings })
    if settings ~= nil then
        print("Changed typeCheckingMode to " .. settings.basedpyright.analysis.typeCheckingMode)
    end
end

-- Custom completion function
local function basedpy_completion_list(_, _, _)
    return { "off", "basic", "standard", "recommended", "strict", "all" }
end

vim.api.nvim_create_user_command("TogglePythonWarnings", function(args)
        toggle_unknown_types(args.args)
    end,
    { nargs = "?", desc = "Toggle basedpyright Warnings", complete = basedpy_completion_list }
)

autocmd("FileType", {
    pattern = { "applescript" },
    callback = function()
        vim.bo.commentstring = "-- %s"
    end,
})

-- Create floating terminal buffer
local function create_floating_terminal()
    -- Get editor dimensions
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create buffer and window
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        focusable = true,
    })

    -- Start zsh terminal, run script, focus, and enter insert mode
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_buf_call(buf, function()
        vim.cmd('terminal zsh -c "nnn -G -p -"')
        vim.cmd("startinsert!")
    end)

    -- Keymaps to close window and buffer with ESC or q
    for _, key in ipairs({ "<Esc>", "q" }) do
        vim.keymap.set({ "n", "t" }, key, function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end, { buffer = 0, silent = true })
    end

    -- Open selected file in new buffer when nnn exits
    autocmd("TermClose", {
        buffer = buf,
        callback = function()
            local output = vim.fn.getbufline(buf, 1, "$")
            local file = output[1]
            if file and vim.fn.filereadable(file) == 1 then
                vim.api.nvim_win_close(win, true)
                vim.cmd("edit " .. vim.fn.fnameescape(file))
                vim.api.nvim_command("filetype detect")
                vim.api.nvim_command("syntax on")
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end,
        once = true,
    })
end

-- Autocommand group
local augroupNnn = vim.api.nvim_create_augroup("Nnn", { clear = true })
autocmd("User", {
    pattern = "Nnn",
    group = augroupNnn,
    callback = create_floating_terminal,
    desc = "Nnn file picker",
})

-- Define :Nnn command
vim.api.nvim_create_user_command("Nnn", function()
    vim.api.nvim_exec_autocmds("User", { pattern = "Nnn" })
end, { desc = "Launch nnn file picker in floating window" })

-- Keymap
vim.keymap.set("n", "<leader>n", ":Nnn<CR>", { desc = "Trigger Nnn floating terminal", silent = true })

vim.api.nvim_create_user_command("ShellCheckDisable", function()
    local line = vim.fn.line(".") - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = line })
    for _, diag in ipairs(diagnostics) do
        if diag.source == "shellcheck" and diag.code then
            local code = string.match(diag.code, "SC%d+") or diag.code
            vim.api.nvim_buf_set_lines(0, line, line, false, { "# shellcheck disable=" .. code })
            return
        end
    end
    vim.notify("No ShellCheck warning found under cursor", vim.log.levels.WARN)
end, { desc = "Disable ShellCheck warning for current line" })

-- Format AppleScript files
vim.api.nvim_create_user_command("FormatAppleScript", function()
    local file = vim.fn.expand("%:p")
    local posix_file = vim.fn.fnameescape(file)
    local cmd = string.format(
        "osadecompile %q > %q.formatted && mv %q.formatted %q",
        posix_file,
        posix_file,
        posix_file,
        posix_file
    )
    local _, err = vim.fn.system(cmd)
    if vim.v.shell_error == 0 then
        vim.cmd("edit") -- Reload buffer
    else
        print("Error formatting AppleScript: " .. err)
    end
end, { desc = "Format AppleScript using osadecompile" })

-- Highlight yanked text
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
})
