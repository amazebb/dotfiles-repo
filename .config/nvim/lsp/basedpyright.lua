return {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "requirements.txt", ".git/" },
  settings = {
    basedpyright = {
      analysis = {
        ignore = { '*' },
      },
      disableOrganizeImports = true, -- Let ruff handle imports
    },
  },
}
