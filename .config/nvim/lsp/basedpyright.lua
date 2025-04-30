return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "requirements.txt", ".git/" },
  settings = {
    basedpyright = {
      analysis = {
        -- autoSearchPaths = true,
        -- diagnosticMode = "openFilesOnly",
        -- useLibraryCodeForTypes = true,
        ignore = { '*' },
      },

      disableOrganizeImports = true, -- Let ruff handle imports
    },
  },
  --  on_attach = function(client)
  -- 	client.server_capabilities.diagnosticProvider = false
  -- end,

}
