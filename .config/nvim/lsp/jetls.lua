---@brief
---
--- https://aviatesk.github.io/JETLS.jl/release/

---@type vim.lsp.Config
return {
    cmd = {
        "jetls",
        "--threads=auto",
        "--",
    },
    filetypes = { "julia" },
    root_markers = { 'Project.toml', 'JuliaProject.toml' }
}
