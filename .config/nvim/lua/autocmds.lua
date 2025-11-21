local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("CmdlineEnter", {
    desc = "When entering command mode show the command line",
    callback = function()
        vim.o.cmdheight = 1
    end,
})

autocmd("CmdlineLeave", {
    desc = "When leaving command mode hide the command line",
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
    desc = "Enable LSP auto-formatting on buffer write",
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
    ---@diagnostic disable: undefined-field
    if settings ~= nil then
        settings.basedpyright.analysis.typeCheckingMode = value == ""
            and (settings.basedpyright.analysis.typeCheckingMode == "standard" and "recommended" or "standard")
            or value
    end
    ---@diagnostic enable: undefined-field

    -- Update LSP client
    client:notify("workspace/didChangeConfiguration", { settings = settings })
    if settings ~= nil then
        --- @diagnostic disable: undefined-field
        print("Changed typeCheckingMode to " .. settings.basedpyright.analysis.typeCheckingMode)
        --- @diagnostic enable: undefined-field
    end
end

-- Custom completion function for basedpyright completion list
local function basedpy_completion_list(_, _, _)
    return { "off", "basic", "standard", "recommended", "strict", "all" }
end

vim.api.nvim_create_user_command("TogglePythonWarnings", function(args)
        toggle_unknown_types(args.args)
    end,
    { nargs = "?", desc = "Toggle basedpyright Warnings", complete = basedpy_completion_list }
)

-- Autocommand group for Nnn
local fun = require("functions")
local augroupNnn = vim.api.nvim_create_augroup("Nnn", { clear = true })
autocmd("User", {
    pattern = "Nnn",
    group = augroupNnn,
    callback = fun.nnn,
    desc = "Nnn file picker",
})

-- Define Nnn command
vim.api.nvim_create_user_command("Nnn", function()
    vim.api.nvim_exec_autocmds("User", { pattern = "Nnn" })
end, { desc = "Launch nnn file picker in floating window" })

-- Disbale ShellCheck warning on current line
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

-- Applescript comment string
autocmd("FileType", {
    pattern = { "applescript" },
    callback = function()
        vim.bo.commentstring = "-- %s"
    end,
})

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
