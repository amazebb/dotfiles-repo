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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- Enable auto-completion
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Enable auto-formatting on save
    if client.supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- noselect prevent from automatically selecting the first completion item in the popup menu
vim.cmd("set completeopt+=noselect")
