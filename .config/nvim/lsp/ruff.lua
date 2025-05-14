return {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    settings = {},
    capabilities = {
        general = {
            -- get rid of pesky encode warning when running :checkhealth lsp
            positionEncodings = { 'utf-16' },
        },
    },
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.completionProvider = false
    end,
}
