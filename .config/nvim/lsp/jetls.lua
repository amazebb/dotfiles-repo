---@brief
---
--- https://aviatesk.github.io/JETLS.jl/release/

---@type vim.lsp.Config
return {
    cmd = {
        "jetls",
        "serve",
    },
    filetypes = { "julia" },
    root_markers = { 'Project.toml' }
}
