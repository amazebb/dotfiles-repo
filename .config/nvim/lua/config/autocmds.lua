vim.api.nvim_create_autocmd('CmdlineEnter', {
    callback = function()
        vim.o.cmdheight = 1
    end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
    callback = function()
        vim.o.cmdheight = 0
    end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    pattern = { '*.lua' },
    callback = function()
        -- more commands if needed
        vim.cmd([[silent! !stylua %]])
    end,
})

vim.api.nvim_create_autocmd('BufDelete', {
    pattern = '*',
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

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        -- Enable auto-completion
        if client and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end

        -- Enable auto-formatting on save
        if client and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = ev.buf,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end

        -- if client.supports_method('textDocument/hover') then
        --   vim.api.nvim_create_autocmd("CursorHold", {
        --     buffer = ev.buf,
        --     callback = function()
        --       vim.lsp.buf.hover()
        --     end,
        --   })
        -- end
    end,
})

-- noselect prevent from automatically selecting the first completion item in the popup menu
vim.cmd('set completeopt+=noselect')

local function show_help_popup(topic)
    vim.cmd('help ' .. (topic or ''))
    local help_buf = vim.api.nvim_get_current_buf()
    -- Close original help window
    vim.cmd('wincmd c')
    -- Clear jumplist for help buffer, this way C-o works correctly when jumping back
    vim.api.nvim_buf_call(help_buf, function()
        vim.cmd('clearjumps')
    end)
    vim.api.nvim_open_win(help_buf, true, {
        relative = 'editor',
        width = math.floor(0.8 * vim.o.columns),
        height = math.floor(0.8 * vim.o.lines),
        row = math.floor(0.1 * vim.o.lines),
        col = math.floor(0.1 * vim.o.columns),
        border = 'rounded',
    })
    vim.bo[help_buf].bufhidden = 'wipe'
    vim.api.nvim_buf_set_keymap(help_buf, 'n', 'q', ':q<cr>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(help_buf, 'n', '<Esc>', ':q<cr>', { noremap = true, silent = true })
end

-- Command for manual use
vim.api.nvim_create_user_command('HelpPopup', function(args)
    show_help_popup(args.args)
end, { nargs = '?' })

-- Toggle basedpyright warnings function
local function toggle_unknown_types(value)
    local client = vim.lsp.get_clients({ name = 'basedpyright' })[1]
    if not client then
        print('basedpyright not running')
        return
    end

    -- Toggle settings
    local settings = client.config.settings
    if settings ~= nil then
        settings.basedpyright.analysis.typeCheckingMode = value == ''
                and (settings.basedpyright.analysis.typeCheckingMode == 'standard' and 'recommended' or 'standard')
            or value
    end

    -- Update LSP client
    client:notify('workspace/didChangeConfiguration', { settings = settings })
    if settings ~= nil then
        print('Changed typeCheckingMode to ' .. settings.basedpyright.analysis.typeCheckingMode)
    end
end

-- Custom completion function
local function completion_list(_, _, _)
    return { 'off', 'basic', 'standard', 'recommended', 'strict', 'all' }
end

vim.api.nvim_create_user_command('TogglePythonWarnings', function(args)
    toggle_unknown_types(args.args)
end, { nargs = '?', desc = 'Toggle basedpyright Warnings', complete = completion_list })

-- Ensure git commit -v shows syntax/color highlighting in the diff
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    pattern = { 'COMMIT_EDITMSG' },
    callback = function()
        -- Apply diff syntax to diff regions
        vim.cmd([[syntax include @Diff syntax/diff.vim]])
        vim.cmd([[syntax region gitcommitDiff start="^diff --git" end="\%$" contains=@Diff]])
    end,
})

vim.api.nvim_create_user_command('GitDiffFileMerge', function()
    vim.fn.jobstart('git difftool --cached', { detach = true })
end, {})
