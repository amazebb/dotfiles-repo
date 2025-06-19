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
vim.opt.completeopt:append('noselect')

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

-- render-markdown
-- Note: Adding this here explcitily otherwise renderer-markdown is not highlighting correctly
-- Should not have to do this but could be an interfering plugin/setting causing the issue
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'quatro', 'codecompanion' },
    callback = function()
        vim.treesitter.start()
    end,
})

vim.api.nvim_create_user_command('ToggleLatex', function()
    _G.latex_enabled = not _G.latex_enabled
    require('render-markdown').setup({ latex = { enabled = _G.latex_enabled } })
end, { desc = 'Toglle Latex rendering in markdown' })
-- render-markdown

vim.api.nvim_create_user_command('GitDiffFileMerge', function()
    vim.fn.jobstart('git difftool --cached', { detach = true })
end, {})

-- -- Basic Neovim configuration for MATLAB-style layout
-- -- Ensure required plugins are installed (e.g., via a plugin manager like packer.nvim)
-- -- Plugins: nvim-tree.lua (file explorer), vim-terminal (terminal)
--
-- -- Function to set up the layout
-- function SetupMatlabLayout()
--     -- Open NvimTree on the left
--     vim.cmd('NnnExplorer')
--
--     -- Split the main window vertically for editor and variables
--     vim.cmd('vsplit')
--
--     -- Move to the right window (editor)
--     vim.cmd('wincmd l')
--
--     -- Split the editor window horizontally for editor and terminal
--     vim.cmd('split')
--
--     -- Open terminal in the bottom window
--     vim.cmd('wincmd j')
--     vim.cmd('terminal')
--     vim.cmd('resize 15') -- Adjust terminal height
--
--     -- Move back to the editor window
--     vim.cmd('wincmd k')
--
--     -- Move to the rightmost window (for variables)
--     vim.cmd('wincmd l')
--     vim.cmd('vertical resize 30') -- Adjust variable window width
--
--     -- Create a new buffer for variable explorer
--     vim.cmd('enew')
--     vim.bo.buftype = 'nofile'
--     vim.bo.bufhidden = 'hide'
--     vim.bo.swapfile = false
--     vim.api.nvim_buf_set_name(0, 'Variables')
-- end
--
-- -- Command to trigger the layout
-- vim.api.nvim_create_user_command('MatlabLayout', SetupMatlabLayout, {})
--
-- -- Keybinding to trigger the layout
-- vim.api.nvim_set_keymap('n', '<leader>ml', ':MatlabLayout<CR>', { noremap = true, silent = true })
--
-- Neovim configuration for three side-by-side buffers

-- Function to set up the layout
function SetupThreeBufferLayout()
    -- Clear all windows
    vim.cmd('only')

    -- Create left buffer
    vim.cmd('enew')
    vim.bo.buftype = 'nofile'
    vim.api.nvim_buf_set_name(0, 'Left')

    -- Create middle buffer
    vim.cmd('vert sb')
    vim.cmd('wincmd l')
    -- Reuse existing file buffer or create new
    local bufs = vim.api.nvim_list_bufs()
    local file_buf = nil
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
            file_buf = buf
            break
        end
    end
    if file_buf then
        vim.api.nvim_set_current_buf(file_buf)
    else
        vim.cmd('enew')
    end

    -- Create right buffer
    vim.cmd('vert sb')
    vim.cmd('wincmd l')
    vim.cmd('enew')
    vim.bo.buftype = 'nofile'
    vim.api.nvim_buf_set_name(0, 'Right')

    -- Set widths
    local total_cols = vim.o.columns
    local side_width = math.floor(total_cols / 6)
    local middle_width = total_cols - 2 * side_width
    vim.cmd('wincmd h') -- Left
    vim.cmd('vertical resize ' .. side_width)
    vim.cmd('wincmd l') -- Middle
    vim.cmd('vertical resize ' .. middle_width)
    vim.cmd('wincmd l') -- Right
    vim.cmd('vertical resize ' .. side_width)
end

-- Auto-resize function
function ResizeThreeBufferLayout()
    local total_cols = vim.o.columns
    local side_width = math.floor(total_cols / 6)
    local middle_width = total_cols - 2 * side_width
    vim.cmd('wincmd h') -- Left
    vim.cmd('vertical resize ' .. side_width)
    vim.cmd('wincmd l') -- Middle
    vim.cmd('vertical resize ' .. middle_width)
    vim.cmd('wincmd l') -- Right
    vim.cmd('vertical resize ' .. side_width)
end

-- Autocommand for resize
vim.api.nvim_create_autocmd('VimResized', {
    callback = ResizeThreeBufferLayout,
})

-- Command and keybinding
vim.api.nvim_create_user_command('ThreeBufferLayout', SetupThreeBufferLayout, {})
vim.api.nvim_set_keymap('n', '<leader>tb', ':ThreeBufferLayout<CR>', { noremap = true, silent = true })

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
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
        focusable = true,
    })

    -- Start zsh terminal, run script, focus, and enter insert mode
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_buf_call(buf, function()
        vim.cmd('terminal zsh -c "nnn -G -p -"')
        vim.cmd('startinsert!')
    end)

    -- Keymaps to close window and buffer with ESC or q
    for _, key in ipairs({ '<Esc>', 'q' }) do
        vim.keymap.set({ 'n', 't' }, key, function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(buf, { force = true })
        end, { buffer = 0, silent = true })
    end

    -- Open selected file in new buffer when nnn exits
    vim.api.nvim_create_autocmd('TermClose', {
        buffer = buf,
        callback = function()
            local output = vim.fn.getbufline(buf, 1, '$')
            local file = output[1]
            if file and vim.fn.filereadable(file) == 1 then
                vim.api.nvim_win_close(win, true)
                vim.cmd('edit ' .. vim.fn.fnameescape(file))
                vim.api.nvim_command('filetype detect')
                vim.api.nvim_command('syntax on')
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end,
        once = true,
    })
end

-- Autocommand group
local augroup = vim.api.nvim_create_augroup('Nnn', { clear = true })
vim.api.nvim_create_autocmd('User', {
    pattern = 'Nnn',
    group = augroup,
    callback = create_floating_terminal,
    desc = 'Nnn',
})

-- Define :Nnn command
vim.api.nvim_create_user_command('Nnn', function()
    vim.api.nvim_exec_autocmds('User', { pattern = 'Nnn' })
end, { desc = 'Open floating terminal with n.sh' })

-- Keymap
vim.keymap.set('n', '<leader>n', ':Nnn<CR>', { desc = 'Trigger Nnn floating terminal', silent = true })
