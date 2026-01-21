# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Core Architecture

This is a personal Neovim configuration built on Neovim's built-in package manager (`vim.pack`). The configuration is modular, with each aspect split into separate files in the `lua/` directory.

### Module Loading Order (init.lua)
1. `configs` - Core Vim settings and options
2. `keymaps` - Key mappings
3. `autocmds` - Autocommands and custom commands
4. `statusline` - Custom statusline implementation
5. `plugins` - Plugin management via vim.pack
6. `lsp` - LSP configuration
7. `ai` - AI integration features

### LSP Architecture

The LSP setup uses Neovim's built-in `vim.lsp.config()` and `vim.lsp.enable()` APIs (not nvim-lspconfig plugin). LSP configurations are:
- Defined in `lua/lsp.lua` for overrides
- Stored in separate files at `~/.config/nvim/lsp/*.lua` (synced from upstream nvim-lspconfig)
- Updated via `<Leader>s` which pulls from `~/Code/GitHub/nvim-lspconfig` and copies relevant configs

The `lsp_enable_list` global variable determines which LSP servers are enabled.

### Plugin Management

Uses Neovim's built-in `vim.pack.add()` with version pinning. Plugins are declared in `lua/plugins.lua`:
- AppleScript syntax highlighting
- fzf-lua for fuzzy finding
- nvim-treesitter for syntax highlighting and parsing
- blink.cmp for completion

Lock file at `nvim-pack-lock.json` tracks installed versions. Update with `:lua vim.pack.update()` or `<Leader>p`.

### AI Integration (lua/ai.lua)

Custom AI integration using X.AI (Grok) API:
- Conventional commit message generation via `<Leader>cc` (uses git diff + AI)
- Billing information via `<Leader>ab`
- API keys retrieved from macOS Keychain via `security` command
- Configurable system prompts for different AI tasks

### Key Systems

**Custom Functions (lua/functions.lua)**:
- `get_password()` - Retrieves credentials from macOS Keychain
- `update_lspconfigs()` - Syncs LSP configs from upstream
- `floating_window()` - Generic floating window creator
- `nnn()` - File picker integration
- `commit_msg_popup()` - Commit message editor
- `pretty_json()` - Formats JSON with jq

**Statusline (lua/statusline.lua)**:
- Custom statusline with git status integration
- Uses external `dotfiles` command for git information
- Shows LSP status, file info, mode, and position
- Toggle symbols with `:StatusLineToggleSymbols`
- Toggle git folder display with `:StatusLineToggleGitFolder`

**File Picker**:
- Nnn integration via `:Nnn` command or `<leader>n`
- Launches in floating window, returns selected file

## Important Conventions

### External Dependencies
This config relies on external shell commands:
- `dotfiles` - Custom git wrapper for statusline and commits
- `jq` - JSON formatting
- `security` - macOS Keychain access
- `nnn` - Terminal file manager
- `qlmanage` - macOS QuickLook for file preview

### Git Commands
**IMPORTANT**: Always use `dotfiles` instead of `git` when running git commands via the Bash tool. This applies to all git operations including status, log, diff, commit, etc.

### Python Environment
Python integration uses a dedicated virtual environment at `~/.config/nvim/py-nvim/.venv/` with debugpy and neovim packages.

### AppleScript Support
Special handling for AppleScript files:
- Custom filetype detection for `.scpt`, `.applescript`, `.scptd`
- Format command `:FormatAppleScript` using `osadecompile`
- Comment string set to `-- %s`

## Common Commands

### LSP Management
- Update LSP configs: `<Leader>s` or call `require("functions").update_lspconfigs()`
- Toggle Python type warnings: `<Leader>w` or `:TogglePythonWarnings [mode]`
  - Modes: off, basic, standard, recommended, strict, all
- Disable ShellCheck warning on current line: `<C-i>` or `:ShellCheckDisable`

### Plugin Management
- Check/update plugins: `<Leader>p` or `:lua vim.pack.update()`

### Navigation & Fuzzy Finding
- Open buffers: `<Leader>b`
- FzfLua menu: `<Leader>f`
- Launch Nnn file picker: `<Leader>n`

### AI Features
- Generate conventional commit: `<Leader>cc`
- Check AI billing: `<Leader>ab`

### Diagnostics
- Show diagnostic under cursor: `<Leader>d`
- Next diagnostic: `]d`
- Previous diagnostic: `[d`
- Diagnostics list: `<Leader>q`

### Utility
- QuickLook preview current file: `<Leader><Leader>`
- Toggle relative/absolute line numbers: `<Leader>l`
- Open terminal below: `<Leader>t`

## Configuration Notes

### Folding
- Uses Treesitter folding by default (`foldmethod=expr`, `foldexpr=v:lua.vim.treesitter.foldexpr()`)
- Falls back to LSP folding when LSP client supports `textDocument/foldingRange`
- All folds open by default (`foldlevelstart=99`)

### Auto-formatting
LSP auto-formatting is enabled on save for all buffers where the LSP server supports formatting.

### Color Scheme
Detects terminal type - uses 256 color mode for xterm-256color, true color otherwise. No external colorscheme plugin.

### LSP Client Lifecycle
Custom autocmd on `BufDelete` stops LSP clients when they're no longer attached to any buffers (prevents orphaned LSP processes).
