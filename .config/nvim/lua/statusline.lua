Statusline = {}

vim.api.nvim_set_hl(0, 'User2', { fg = '#FFFF00' })
vim.api.nvim_set_hl(0, 'User3', { fg = '#8B0000' })
vim.api.nvim_set_hl(0, 'User4', { fg = '#aaff00' })
vim.api.nvim_set_hl(0, 'User5', { fg = '#0099ff' })
vim.api.nvim_set_hl(0, 'User6', { fg = '#fB4500' })
vim.api.nvim_set_hl(0, 'User7', { fg = '#00FF00' })

local LHS_ITEM_SEP = " | "
local RHS_ITEM_SEP = " | "
local git_status = ""
local lsp_status = false

local function toggle_git_folder()
    vim.g.enable_git_folder = not vim.g.enable_git_folder
end

local function toggle_symbols()
    vim.g.statusline_symbols = not vim.g.statusline_symbols
end

local function update_git_status()
    -- NOTE For some reason opening Kitty config errors on finding dotfiles
    -- Seems it does not have the same PATH as running nvim normally ?
    local res = vim.system({ "sh", "-c", "dotfiles stline" }, { text = true })
    git_status = vim.trim(res:wait().stdout)
    -- Enter 5-digit hex code in Insert mode: <C-r>=nr2char(0xf062c)
    -- For regular 4-code ie. e0a0, in Insert mode: <C-v> u e0a0
    if git_status ~= "" then
        if vim.g.enable_git_folder then
            local obj = vim.system({ 'dotfiles', 'rev-parse', '--absolute-git-dir' }, { text = true }):wait()
            local git_dir = vim.trim(obj.stdout or ""):gsub("^" .. vim.pesc(vim.env.HOME), "~")
            local git_folder = (vim.g.statusline_symbols and " " or "") .. git_dir
            git_status = git_folder ..
                LHS_ITEM_SEP .. (vim.g.statusline_symbols and "󰘬 " or "") .. git_status .. LHS_ITEM_SEP
        else
            git_status = (vim.g.statusline_symbols and "󰘬 " or "") .. git_status .. LHS_ITEM_SEP
        end

        local name = vim.api.nvim_buf_get_name(0)
        if name ~= "" then
            local is_untracked = vim.system({ "sh", "-c", "dotfiles ls-files --error-unmatch " ..
            vim.fn.expand("%:p") .. " 2>/dev/null" }):wait() == ""
            if is_untracked then
                git_status = git_status .. "%#CurSearch#󰡯 "
            end
        end
    end
end

local function update_lsp_status()
    lsp_status = #vim.lsp.get_clients({ bufnr = 0 }) > 0
end

function Statusline.set_statusline()
    local mode = vim.api.nvim_get_mode().mode:gsub("%c", "")
    local mode_name = ({ n = "NORMAL", i = "INSERT", v = "VISUAL", V = "VISUAL",
            s = "SELECT", S = "SELECT", R = "REPLACE", c = "COMMAND", r = "PROMPT", t = "TERM", ["!"] = "SHELL" })
        [mode:sub(1, 1)] or mode
    local colors = {
        NORMAL = "1",
        INSERT = "2",
        VISUAL = "4",
        SELECT = "5",
        REPLACE = "6",
        COMMAND = "7",
        TERM = "5",
        PROMPT = "5",
        SHELL = "5"
    }
    local hlMode = "%" .. (colors[mode_name] or "") .. "*"
    if mode == "t" then
        return hlMode .. mode_name .. "%*"
    else
        return hlMode .. mode_name .. "%*"
            .. LHS_ITEM_SEP ..
            git_status ..
            "%F %6*%m%* %=%Y " ..
            (lsp_status and (vim.g.statusline_symbols and "󱐋" or "[LSP]") or "") .. RHS_ITEM_SEP .. "%P %l:%c "
    end
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
    -- TODO Consider some of these, but seems to be working ok..
    -- "FocusGained", "DirChanged", "TermClose"
    group = group,
    desc = "Activate statusline on focus",
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "" then
            update_git_status()
            update_lsp_status()
            vim.opt_local.statusline = '%!v:lua.Statusline.set_statusline()'
        end
    end
})

vim.api.nvim_create_user_command("StatusLineToggleSymbols", function()
    toggle_symbols()
    update_git_status()
    update_lsp_status()
end, { desc = "Toggle the statusline symbols" })

vim.api.nvim_create_user_command("StatusLineToggleGitFolder", function()
    toggle_git_folder()
    update_git_status()
end, { desc = "Toggle the statusline git folder" })
