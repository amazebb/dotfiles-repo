vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		vim.o.cmdheight = 1
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		vim.o.cmdheight = 0
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	pattern = "*",
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
				client.stop(true)
			end
		end
	end,
})

-- vim.api.nvim_create_autocmd("CursorMoved", {
-- 	pattern = "*",
-- 	callback = function()
-- 		local cur_pos = vim.api.nvim_win_get_cursor(0)
-- 		local col = cur_pos[2]
-- 		local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
-- 		if not char:match("[%(%){%[%]%)]") then
-- 			return
-- 		end
--
-- 		-- Jump to match, get pos, return
-- 		vim.cmd("normal! %")
-- 		local match_pos = vim.api.nvim_win_get_cursor(0)
-- 		vim.api.nvim_win_set_cursor(0, cur_pos)
--
-- 		-- Check if off-screen
-- 		local match_line = match_pos[1]
-- 		local top = vim.fn.line("w0")
-- 		local bottom = vim.fn.line("w$")
-- 		if match_line >= top and match_line <= bottom then
-- 			return
-- 		end
--
-- 		-- Popup
-- 		local msg = "Match at line " .. match_line .. ": " .. vim.fn.getline(match_line)
-- 		local buf = vim.api.nvim_create_buf(false, true)
-- 		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })
-- 		local opts = {
-- 			relative = "cursor",
-- 			row = 1,
-- 			col = 1,
-- 			width = #msg + 2,
-- 			height = 1,
-- 			style = "minimal",
-- 			border = "single",
-- 		}
-- 		local win = vim.api.nvim_open_win(buf, false, opts)
-- 		vim.defer_fn(function()
-- 			vim.api.nvim_win_close(win, true)
-- 		end, 1500)
-- 	end,
-- })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.cmd("set completeopt+=noselect")
