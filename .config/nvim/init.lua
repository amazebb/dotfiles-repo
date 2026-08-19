-- Prefer local clone for fast iteration (no push + packupdate).
-- Usage: NVIM_CONFIG_DEV=1 nvim   (or shell alias `nnd`)
local dev = vim.fn.expand("~/Code/GitHub/amazebb/nvim-config")
if vim.env.NVIM_CONFIG_DEV == "1" and vim.uv.fs_stat(dev) then
  vim.opt.runtimepath:prepend(dev)
else
  vim.pack.add({ "https://github.com/amazebb/nvim-config" })
end

require "init"
