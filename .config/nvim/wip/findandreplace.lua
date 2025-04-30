vim.keymap.set("n", "<C-f>", function()
  local buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
  local width = 40
  local height = 4
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "single",
  })

  -- Set initial lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "Find: ",
    "Replace: ",
    "",
    "Next(n) Replace(r) All(a)",
  })

  -- Make editable only after "Find: " and "Replace: "
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  local find_col = #"Find: " + 1
  local replace_col = #"Replace: " + 1

  -- Move cursor to Find line
  vim.api.nvim_win_set_cursor(win, { 1, find_col - 1 })

  -- Keymaps for n, r, a
  vim.keymap.set("n", "n", function()
    local find_text = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:sub(find_col))
    if find_text ~= "" then
      vim.fn.setreg("/", find_text)
      vim.cmd("normal! n")
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "r", function()
    local find_text = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:sub(find_col))
    local replace_text = vim.trim(vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]:sub(replace_col))
    if find_text ~= "" then
      vim.fn.setreg("/", find_text)
      vim.cmd("normal! n")
      vim.api.nvim_put({ replace_text }, "c", false, true)
    end
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "a", function()
    local find_text = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]:sub(find_col))
    local replace_text = vim.trim(vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]:sub(replace_col))
    if find_text ~= "" then
      vim.api.nvim_win_close(win, true)
      vim.cmd(":%s/" .. vim.fn.escape(find_text, "/") .. "/" .. vim.fn.escape(replace_text, "/") .. "/g")
    end
  end, { buffer = buf, silent = true })

  -- Close on <Esc>
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })
end, { desc = "Open find/replace float" })
