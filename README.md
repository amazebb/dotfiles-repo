## dotfiles

This documents all things dotfiles related on our MacOS setup.

Will include zsh scripting, and Neovim configuration, and anything else that we can consider dotfiles related

<details>
<summary><h4>Setting up dotfiles repository</h4></summary>

1. **Set up the bare repo in $HOME** (if you haven’t yet):
   ```bash
   git init --bare $HOME/.dotfiles
   alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles config --local status.showUntrackedFiles no
   ```
   Add that alias to your `.zshrc` or `.bashrc` so it sticks.
   
   The above alias is added to ~/.local/bin/dotfiles.sh to help facilitate calling from xargs for instance where aliases dont work
   It also works with p10k status line as well as adds better support for dotfiles status and clean

2. **Add and commit your dotfiles**:
   ```bash
   dotfiles add .zshrc .vimrc  # or whatever you want to track
   dotfiles commit -m "Initial dotfiles commit"
   ```

3. **Create a repo in Gitea**:
   - Log into your Gitea web UI.
   - Hit "New Repository," name it something like `dotfiles`, keep it private if you want, and create it. Skip initializing with a README since you’ll push to it.

4. **Link your local bare repo to Gitea**:
   - Grab the repo URL from Gitea (e.g., `http://localhost:3000/username/dotfiles.git` or SSH if you’ve got that set up).
   - In your terminal:
     ```bash
     dotfiles remote add origin http://localhost:3000/username/dotfiles.git
     dotfiles push -u origin master
     ```

5. **Push updates whenever**:
   - After tweaking dotfiles, just:
     ```bash
     dotfiles add .zshrc
     dotfiles commit -m "Updated zshrc"
     dotfiles push
     ```

That’s it. Your local Gitea will now mirror your dotfiles repo. Since it’s bare, there’s no working tree cluttering $HOME, and Gitea handles the remote storage and browsing. If you’re on another machine, you can clone it with:
```bash
git clone --bare http://localhost:3000/username/dotfiles.git $HOME/.dotfiles
```

Then set up the alias again and pull.

Works like a charm with Gitea, GitLab, or any git server. Just make sure your Gitea instance is accessible where you need it—local LAN or VPN if you’re syncing across devices.

Also see [here](https://askubuntu.com/a/1316230) 
</details>

<details>
<summary><h4>Custom shell scripts</h4></summary>

A collection of personal shell scripts in ~/.local/scripts

Run `:r !~/.local/scripts/list-scripts.sh` in vim to refresh the list below.

```
```
check-scripts.sh    	#!/bin/bash              	Run shellcheck to identify script issues.
compare-folders.sh  	#!/bin/bash              	Compare folders using diff command.
data-backup.sh      	#!/bin/bash              	Backup to SPARSE image in iCloud.
disk-useage.sh      	#!/bin/dash              	Analyze disk usage by folder size.
fz.sh               	#!/opt/homebrew/bin/bash 	Search text interactively with ripgrep, fzf.
generate-script.sh  	#!//usr/bin/env bash     	Generate shell script with inputs, options.
git-wrapper.sh      	#!/opt/homebrew/bin/bash 	Manage dotfiles with Git bare repo.
gitea-cli.sh        	#!/bin/dash              	Manage Gitea: start, stop, status, logs.
github-info.sh      	#!/usr/bin/env bash      	GitHub repo information
info2vim.sh         	#!/bin/dash              	Launch GNU info for coreutils in Neovim.
list-scripts.sh     	#!/bin/dash              	List scripts with descriptions in ~/.local/scripts.
n.sh                	#!/bin/dash              	Launch nnn with preview in tmux.
pre-rg.sh           	#!/usr/bin/env sh        	Pre-process PDFs, ZSDs for fz, ripgrep.
print-ascii.sh      	#!/bin/bash              	Print ASCII codes for number range.
print-colors.sh     	#!/bin/bash              	Show all 256 ANSI terminal colors.
select-manpath.sh   	#!/bin/zsh               	Get MANPATH entries as array.
</details>

<details>
<summary><h4>MacOS Terminal.app color quirks</h4></summary>

There is a quirk with setting colors on MacOS (15.5 and earlier) using Terminal.app with zsh (5.9 arm64-apple-darwin24.0). Not tested with other shells, but suspect its not related to which shell is used.

For instance if we try to set the foreground and background to the same blue, ```%F{blue}``` and ```%K{blue}```, 
they will look different in the Terminal.app.

No amount of using the expansions with named, ```blue```, or numeric values, ```004```, 
or trying to reset the colors using ```%k``` or ```%f``` seems to fix it.

The fix is, instead of using ```%k``` to reset the background, we need to use a number that is out of range of Terminals 0-255 colors,
and to use it with an [escape sequence](https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604) ```e[48;5;256m```

So instead of matching the right trianlge foreground color to the background of previous space character
```zsh
print -P "%K{blue} %k%F{blue}\uE0B0"
```

We do the following:

```zsh
print -P "%K{blue} \e[48;5;256m%F{blue}\uE0B0"
```

Here is [Grok](https://grok.com/share/bGVnYWN5_44f1eb29-e093-436e-8b53-7a0206ae3725) 
just absolutely struggling with this on 4/17/25
</details>


<details>
<summary><h4>Neovim Tips</h4></summary>

Format all Lua files under current folder recursively:

```vim
:args **/*.lua
:argdo lua vim.lsp.buf.format()
```

</details>

<details>
<summary><h4>Storing private information</h4></summary>

We can use MacOS `security` CLI to create secure keys and passwords

```bash
security add-generic-password -a "$USER" -s "xai-api-key" -w "your-api-key-here"
# Neovim command for use with codecompanion.nvim
api-key = "cmd: security find-generic-password -s xai-api-key -w 2>/dev/null"
```

The OpenAI Chat API, including when used with `mlx-lm` (a framework for running LLMs locally), typically returns structured JSON responses for the `/v1/chat/completions` endpoint, even in streaming mode. There isn't a built-in option to get a plain text response without JSON fields directly from the API, as the JSON structure is part of the OpenAI API specification for consistent data handling (e.g., including `choices`, `delta`, and `content` fields in streaming). However, you can process the streamed JSON to extract only the plain text content for your use case with `pynvim` in a Neovim buffer.
</details>

<details>
<summary><h4>Streaming LLM chat using Python into Neovim</h4></summary>
Here’s how you can achieve this:

### Approach
1. **Use `mlx-lm` with OpenAI-compatible API**: `mlx-lm` provides an OpenAI-compatible endpoint (e.g., `http://127.0.0.1:8080/v1`) for local LLMs, which supports the `/v1/chat/completions` endpoint with streaming.
2. **Stream and Parse JSON**: Use Python with `pynvim` to handle the streaming response, extract the `delta.content` field (where the actual text resides), and append it to a Neovim buffer in real-time.
3. **Minimize Overhead**: Skip unnecessary JSON fields during parsing to keep the process lightweight and fast.

### Code Example
Below is a Python script using `pynvim`, `requests` (for streaming), and `mlx-lm` to stream plain text into a Neovim buffer:

```python
import pynvim
import requests
import json

# Connect to Neovim
nvim = pynvim.attach('socket', path='/tmp/nvim')

# API endpoint (mlx-lm local server)
url = "http://127.0.0.1:8080/v1/chat/completions"
headers = {"Content-Type": "application/json"}
payload = {
    "model": "llama-3.1-8b",  # Replace with your model
    "messages": [{"role": "user", "content": "Tell me a short story."}],
    "stream": True
}

# Stream the response
with requests.post(url, json=payload, headers=headers, stream=True) as response:
    buffer = nvim.current.buffer  # Get current Neovim buffer
    for line in response.iter_lines():
        if line:
            # Decode and clean up the streamed line
            line = line.decode('utf-8').strip()
            if line.startswith("data: "):
                line = line[6:]  # Remove "data: " prefix
                if line == "[DONE]":
                    break
                try:
                    # Parse JSON and extract content
                    data = json.loads(line)
                    content = data.get("choices", [{}])[0].get("delta", {}).get("content", "")
                    if content:
                        # Append to Neovim buffer
                        nvim.command('normal! Go')  # Move to end and insert new line
                        buffer.append(content)
                        nvim.command('redraw')  # Refresh buffer display
                except json.JSONDecodeError:
                    pass  # Skip malformed JSON
```

### Key Points
- **Streaming JSON Parsing**: The OpenAI-compatible streaming response sends chunks prefixed with `data: `, each containing a JSON object. You extract the `delta.content` field, which holds the plain text.
- **Neovim Integration**: `pynvim` lets you append text directly to the buffer. The `normal! Go` command ensures text is added at the end, and `redraw` updates the display in real-time.
- **Performance**: By only processing the `delta.content` field and ignoring other JSON fields, you minimize overhead. The `requests` library with `iter_lines` is efficient for streaming.
- **mlx-lm**: Ensure your `mlx-lm` server is running (e.g., `python -m mlx_lm.server --model llama-3.1-8b`). The endpoint mimics OpenAI’s API, so the JSON structure is similar.

### Limitations
- **No Native Plain Text Mode**: Neither OpenAI’s API nor `mlx-lm`’s OpenAI-compatible endpoint offers a plain text-only response for `/v1/chat/completions`. You must parse the JSON stream.
- **JSON Overhead**: The JSON structure adds some overhead, but it’s minimal in practice, especially with efficient parsing as shown above.
- **Alternative Endpoints**: The `/v1/completions` endpoint (not chat) is deprecated by OpenAI and may not be supported by `mlx-lm`. It’s also JSON-based, so it doesn’t solve the plain text issue.

### Tips
- **Error Handling**: Add robust error handling for network issues or malformed JSON, as streaming can be sensitive to interruptions.
- **Buffer Management**: If you want to overwrite the buffer instead of appending, modify the `buffer` operations (e.g., `buffer[:] = [content]`).
- **Model Selection**: Ensure the `model` in the payload matches the one loaded in `mlx-lm`.

If you need a specific tweak (e.g., different buffer handling or model config), let me know!
</details>

<details>
<summary><h4>Plain text streaming in mlx-lm</h4></summary>

You're correct—there's no fundamental barrier to implementing plain text streaming in `mlx-lm` to minimize data transmission. The JSON structure in the OpenAI-compatible `/v1/chat/completions` endpoint is a design choice for compatibility and structured data handling, but a custom plain text streaming endpoint could be added to `mlx-lm` with minimal overhead. This would involve modifying the `mlx_lm.server` code or creating a new endpoint. A pull request (PR) to the `mlx-lm` repo is a viable option if the change aligns with the project's goals. Here's a concise breakdown of how to approach this:

### Feasibility
- **Current Setup**: `mlx-lm` uses FastAPI to serve an OpenAI-compatible API (`/v1/chat/completions`), which streams JSON chunks prefixed with `data: ` (Server-Sent Events, SSE). Each chunk includes fields like `choices` and `delta.content`.
- **Plain Text Streaming**: You could add a new endpoint (e.g., `/v1/stream/text`) that skips JSON formatting and streams only the `content` as plain text. This reduces data overhead (no JSON keys, no `data: ` prefixes) and simplifies client-side parsing for your Neovim use case.
- **Data Savings**: JSON overhead is small but non-zero (e.g., `{"choices":[{"delta":{"content":"text"}}]}` vs. `text`). For long streams, plain text could save 50-70% of the data, depending on content length.
- **Challenges**: Modifying `mlx-lm` requires understanding its inference pipeline and ensuring the new endpoint integrates with the existing model serving logic. You'd also need to handle streaming state (e.g., token-by-token generation) without breaking compatibility.

### Hacking `mlx-lm`
To prototype this, you’d modify the `mlx_lm/server.py` file (or related modules) in the `mlx-lm` repo. Here’s a high-level plan:

1. **Locate the Streaming Logic**:
   - In `mlx_lm/server.py`, find the `chat_completions` endpoint (likely using FastAPI’s `@app.post("/v1/chat/completions")`).
   - The streaming response uses a generator to yield JSON chunks, calling the model’s `generate` or `stream` method (e.g., `model.generate` from `mlx_lm.utils`).

2. **Add a New Endpoint**:
   - Create a new FastAPI route, e.g., `@app.post("/v1/stream/text")`.
   - Reuse the existing model inference logic but skip JSON serialization.
   - Stream raw `content` as plain text using FastAPI’s `StreamingResponse`.

3. **Example Patch (Pseudo-code)**:
```python
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from mlx_lm.server import app, load_model  # Existing imports

@app.post("/v1/stream/text")
async def stream_text(request: Request):
    data = await request.json()
    model, tokenizer = load_model(data.get("model", "llama-3.1-8b"))
    prompt = data.get("messages", [])[-1]["content"]

    async def generate():
        for token in model.generate(prompt, tokenizer, stream=True):
            yield token  # Stream raw token text
        yield "[DONE]"

    return StreamingResponse(generate(), media_type="text/plain")
```

4. **Update Client Code**:
   - Modify your `pynvim` script to hit the new `/v1/stream/text` endpoint.
   - Since it’s plain text, no JSON parsing is needed—just append the streamed text to the Neovim buffer.

```python
import pynvim
import requests

nvim = pynvim.attach('socket', path='/tmp/nvim')
url = "http://127.0.0.1:8080/v1/stream/text"
payload = {
    "model": "llama-3.1-8b",
    "messages": [{"role": "user", "content": "Tell me a short story."}]
}

with requests.post(url, json=payload, stream=True) as response:
    buffer = nvim.current.buffer
    for line in response.iter_lines():
        if line:
            content = line.decode('utf-8').strip()
            if content == "[DONE]":
                break
            buffer.append(content)
            nvim.command('redraw')
```

### Creating a Pull Request
If you want to contribute this to `mlx-lm`, here’s how to proceed:
1. **Fork and Clone**: Fork the `mlx-lm` repo (likely `https://github.com/ml-explore/mlx-lm`), clone it, and create a branch (`git checkout -b plain-text-streaming`).
2. **Implement Changes**: Add the new endpoint and test locally with your `pynvim` setup.
3. **Add Tests**: Include unit tests (e.g., using `pytest`) to verify the endpoint streams correctly and handles edge cases (e.g., empty prompts, model errors).
4. **Document**: Update `README.md` or docs to describe the new `/v1/stream/text` endpoint, including its purpose (e.g., lightweight streaming for low-bandwidth clients).
5. **Submit PR**: Push your branch, open a PR on GitHub, and explain the use case (e.g., “Adds plain text streaming endpoint for minimal data overhead, ideal for real-time text applications like Neovim integration”).
6. **Community Feedback**: The `mlx-lm` maintainers may request changes, like ensuring compatibility with existing features or adding configuration options (e.g., toggle JSON vs. plain text).

### Considerations
- **Maintainer Buy-In**: The `mlx-lm` team may hesitate to add non-OpenAI-compatible endpoints unless there’s strong community demand. Pitch it as a lightweight alternative for specific use cases (e.g., terminal-based apps).
- **Configurability**: Instead of a new endpoint, you could propose a query parameter (e.g., `?format=plain`) to the existing `/v1/chat/completions` endpoint to toggle plain text output.
- **Performance**: Plain text streaming should be slightly faster due to reduced serialization overhead, but test to quantify the gain (e.g., measure latency and bandwidth).
- **Local Hack vs. PR**: If the change is just for your setup, hack it locally and skip the PR. Use a custom branch or fork to avoid conflicts with upstream updates.

### Next Steps
- **Prototype Locally**: Check out the `mlx-lm` source (likely in `~/.pyenv/versions/<your-python-version>/lib/pythonX.X/site-packages/mlx_lm` or the GitHub repo). Experiment with the above pseudo-code.
- **Test with Neovim**: Verify the new endpoint streams cleanly into your buffer without JSON cruft.
- **Decide on PR**: If you think it’s broadly useful, prep a PR. If not, keep it as a local mod.

If you want help with specific `mlx-lm` code (e.g., exact files to edit) or drafting the PR, let me know!
</details>

<details>
<summary><h4>statusline customization</h4></summary>

Neovim’s status line is a customizable, per-window bar at the bottom of each window that displays information about the current buffer, cursor position, or other editor state. Without plugins like `lualine`, you can configure it natively using the `statusline` option, which supports static text, dynamic expressions, and even simple animations (e.g., a progress bar). Since you’re a terminal-savvy user with a full dev setup (Neovim, Lua, M1 MacBook Pro), I’ll keep this concise, focusing on barebones status lines, how they work, and how to create a simple custom one with text and a progress bar.

### How Status Lines Work in Neovim
- **Definition**: The status line is controlled by the `statusline` option (`:set statusline=...`), a string that combines static text, format specifiers (e.g., `%f` for file name), and Vim expressions (e.g., `%{...}` for dynamic content).
- **Scope**: Per-window, but can be global (`:set global statusline=...`) or local to a window (`:set local statusline=...`).
- **Rendering**: Neovim evaluates `statusline` each time the screen redraws (e.g., cursor move, buffer change), allowing dynamic updates.
- **Components**:
  - **Static Text**: Plain strings (e.g., `"My Status"`).
  - **Specifiers**: `%` codes like `%f` (file name), `%l` (line number), `%p` (percentage through file).
  - **Expressions**: `%{LuaOrVimScript}` for dynamic content (e.g., `%{line('.')*100/line('$')}%` for progress).
  - **Alignment**: `%=` separates left- and right-aligned sections.
  - **Colors**: Highlight groups (e.g., `hi StatusLine guifg=#ffffff guibg=#000000`) for styling.

### Barebones Status Line (No Plugins)
By default, Neovim’s status line is minimal (e.g., shows file name, line/column). To customize it without plugins:

1. **Set a Simple Static Status Line**:
   Add to `~/.config/nvim/init.lua`:
   ```lua
   vim.opt.statusline = "My Custom Status"
   ```
   - Shows “My Custom Status” in every window’s status line.
   - Test immediately: `:set statusline=My\ Custom\ Status`.

2. **Add Dynamic Info**:
   Include file name and line number:
   ```lua
   vim.opt.statusline = "%f [%l:%c]"
   ```
   - `%f`: Relative path of the file.
   - `%l`: Current line number.
   - `%c`: Column number.
   - Example output: `path/to/file.txt [10:5]`.

3. **Left and Right Alignment**:
   Show file name on left, line info on right:
   ```lua
   vim.opt.statusline = "%f %= Line %l/%L"
   ```
   - `%=`: Pushes subsequent content to the right.
   - `%L`: Total lines in buffer.
   - Example: `path/to/file.txt             Line 10/100`.

4. **Highlighting**:
   Add color using highlight groups:
   ```lua
   vim.api.nvim_set_hl(0, "StatusLine", { fg = "#00FF00", bg = "#000000" })
   vim.opt.statusline = "%#StatusLine#%f %= Line %l/%L"
   ```
   - `%#StatusLine#`: Applies the `StatusLine` highlight group (green text, black background).
   - Persists across sessions if in `init.lua`.

### Creating a Simple Progress Bar
To animate a progress bar (e.g., showing scroll position), use a Lua function within `statusline` to compute the bar dynamically. Here’s how:

1. **Basic Progress Bar**:
   Show a text-based bar (e.g., `[####    ]`) based on cursor position:
   ```lua
   local function progress_bar()
       local current = vim.fn.line('.')
       local total = vim.fn.line('$')
       local width = 10 -- Bar width
       local filled = math.floor(current * width / total)
       local empty = width - filled
       return '[' .. string.rep('#', filled) .. string.rep(' ', empty) .. ']'
   end

   vim.opt.statusline = '%f %=' .. progress_bar() -- Static call (won’t update)
   ```
   - Issue: This sets the statusline once, so the bar doesn’t update dynamically.

2. **Dynamic Progress Bar**:
   Use `%{...}` to evaluate the function on each redraw:
   ```lua
   local function progress_bar()
       local current = vim.fn.line('.')
       local total = vim.fn.line('$')
       local width = 10
       local filled = math.floor(current * width / total)
       local empty = width - filled
       return '[' .. string.rep('#', filled) .. string.rep(' ', empty) .. ']'
   end

   vim.opt.statusline = '%f %= %{luaeval("progress_bar()")}'
   ```
   - `%{luaeval("progress_bar()")}`: Calls the Lua function on each redraw.
   - Output: `path/to/file.txt [#####     ]` (updates as you scroll).
   - `%p%%` could also show percentage (e.g., `50%`), but the bar is more visual.

3. **Animated Effect (Optional)**:
   For a pseudo-animated bar (e.g., cycling characters), add a timer-based update:
   ```lua
   local chars = {'-', '\\', '|', '/'}
   local idx = 1

   local function progress_bar()
       local current = vim.fn.line('.')
       local total = vim.fn.line('$')
       local width = 10
       local filled = math.floor(current * width / total)
       local empty = width - filled
       idx = idx % #chars + 1 -- Cycle through chars
       return '[' .. string.rep(chars[idx], filled) .. string.rep(' ', empty) .. ']'
   end

   -- Update statusline periodically
   vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
       callback = function()
           vim.opt.statusline = '%f %= %{luaeval("progress_bar()")}'
       end,
   })
   ```
   - Updates the bar on cursor movement, cycling through `-`, `\`, `|`, `/` for a spinning effect.
   - Minimal performance impact on your M1 MacBook Pro.

### Example: Complete Custom Status Line
Combine file info, progress bar, and highlights:
```lua
-- Define highlight
vim.api.nvim_set_hl(0, "StatusLine", { fg = "#00FF00", bg = "#000000" })

-- Progress bar function
local function progress_bar()
    local current = vim.fn.line('.')
    local total = vim.fn.line('$')
    local width = 10
    local filled = math.floor(current * width / total)
    local empty = width - filled
    return '[' .. string.rep('#', filled) .. string.rep(' ', empty) .. ']'
end

-- Set statusline
vim.opt.statusline = '%#StatusLine#%f [%m] %= %l:%c %{luaeval("progress_bar()")}'
```
- `%f`: File name.
- `[%m]`: Modified flag (e.g., `[+]` if unsaved).
- `%l:%c`: Line and column.
- `progress_bar()`: Dynamic bar.
- Output: `path/to/file.txt [+]             10:5 [####      ]`.

### Key Notes
- **Performance**: Native `statusline` is lightweight, even with Lua functions. No plugins mean no overhead (unlike `lualine`).
- **Limitations**: No built-in animations beyond redraw triggers (`CursorMoved`, timers). Complex animations need timers or autocommands.
- **Terminal.app**: Your setup supports true color, so highlights work well. Test in Terminal.app to ensure bar characters render cleanly.
- **Extensibility**: Add more `%{luaeval(...)}` calls for custom logic (e.g., git branch, file encoding).
- **Debugging**: If the statusline breaks, check `:set statusline?` or simplify the expression.

### Your Context
- **Why Barebones?**: You’re already using `lualine`, but a custom `statusline` gives you full control, avoids plugin bloat, and suits your minimalist Neovim preference.
- **Simple Text**: Start with static text (`"My Status"`) or dynamic info (`%f %l/%L`).
- **Progress Bar**: The Lua-based bar above is simple yet visual, perfect for tracking scroll position without `lualine`’s complexity.
- **Next Steps**: If you want more (e.g., git status, mode indicators), extend with Lua or reconsider `lualine` for prebuilt components.

If you need a specific statusline feature (e.g., mode-based colors, git integration) or help debugging, let me know!
</details>


<details>
<summary><h4>Working with tree-sitter queries and syntax</h4></summary>

Working with Tree-sitter syntax in Neovim, particularly in `.scm` (Scheme-like) query files, involves defining queries to manipulate syntax trees for features like syntax highlighting, code folding, or text objects. These files use a LISP-like S-expression syntax to capture specific nodes in a Tree-sitter parse tree. Below, I’ll explain how to work with `.scm` files, provide examples, and point to relevant resources, including Neovim’s built-in documentation and online references.

---

### Understanding Tree-sitter `.scm` Files

Tree-sitter is a parsing library integrated into Neovim for fast, accurate syntax analysis. The `.scm` files contain queries that define how to match and capture nodes in the syntax tree for a specific language. These queries are used for:
- **Syntax highlighting** (`highlights.scm`): Assign highlight groups to code elements.
- **Code folding** (`folds.scm`): Define foldable regions.
- **Text objects** (`textobjects.scm`): Enable navigation or selection of code blocks.
- **Indentation** (`indents.scm`): Control indentation behavior.
- **Injections** (`injections.scm`): Handle embedded languages (e.g., JavaScript in HTML).

The syntax is based on S-expressions, with a structure like `(node_type [child_nodes] @capture_name)`. For example:
```scm
(if_statement ["if" "elseif" "else" "then" "end"] @conditional)
```
This query captures Lua’s `if_statement` nodes (keywords like `if`, `else`) and tags them as `@conditional` for highlighting.

---

### How to Work with `.scm` Files

1. **Locate or Create `.scm` Files**:
   - Neovim looks for `.scm` files in the `queries/<language>/` directory within its `runtimepath` (e.g., `~/.config/nvim/queries/lua/highlights.scm`).
   - For a language like Lua, you might find or create `highlights.scm` to define highlighting rules.
   - If using the `nvim-treesitter` plugin, parsers and queries are often installed automatically under `~/.local/share/nvim/site/pack/*/start/nvim-treesitter/queries/`.

2. **Write a Query**:
   - **Basic Structure**: A query consists of patterns to match nodes in the syntax tree. For example:
     ```scm
     (function_declaration name: (identifier) @function.name)
     ```
     This captures the `identifier` node in a `function_declaration` as `@function.name`.
   - **Capture Names**: Use `@<name>` to tag nodes. For highlighting, these names (e.g., `@function.name`) map to highlight groups.
   - **Node Types**: Refer to the language’s Tree-sitter grammar to know node types (e.g., `if_statement`, `identifier`). Use `:TSPlaygroundToggle` to inspect the syntax tree in Neovim.
   - **Predicates**: Add conditions like `(#eq? @capture "value")` to filter matches. See `:help treesitter-predicates` for supported predicates.

3. **Test and Apply Queries**:
   - Place the `.scm` file in `~/.config/nvim/queries/<language>/<feature>.scm` (e.g., `highlights.scm`).
   - Open a file of the target filetype (e.g., `.lua`) and enable Tree-sitter with `:TSBufEnable highlight`.
   - To reload changes without restarting Neovim:
     - Run `:lua require('nvim-treesitter.query').invalidate_query_cache()` to clear the query cache.
     - Destroy the highlighter for the current buffer: `:lua require('vim.treesitter.highlighter').active[vim.api.nvim_get_current_buf()]:destroy()`.
     - Reload the file with `:e` or restart Neovim.
   - Use `:Inspect` to check highlight groups under the cursor or `:TSPlaygroundToggle` to view the syntax tree.

4. **Debugging**:
   - If highlighting doesn’t work, ensure the parser is installed (`:TSInstall <language>`) and the filetype is registered (`:set filetype?`).
   - Check for errors with `:checkhealth nvim-treesitter`.
   - Verify the query file’s path is in `runtimepath` using `:echo nvim_get_runtime_file('queries/<language>/*.scm', v:true)`.

5. **Customizing Highlight Groups**:
   - Captures like `@conditional` map to highlight groups (e.g., `TSConditional` or `@conditional` in Neovim 0.8+).
   - Link these to Vim highlight groups in your colorscheme:
     ```lua
     vim.api.nvim_set_hl(0, "@conditional", { link = "Conditional" })
     ```
   - Use `:help treesitter-highlight-groups` for details.

---

### Example: Creating a `highlights.scm` for Lua

Here’s a simple `highlights.scm` for Lua syntax highlighting:
```scm
; Highlight keywords
["if" "elseif" "else" "then" "end"] @keyword.conditional

; Highlight function names
(function_declaration name: (identifier) @function.name)

; Highlight parameters
(parameters (identifier) @variable.parameter)

; Highlight strings
(string) @string
```
- Save this in `~/.config/nvim/queries/lua/highlights.scm`.
- Open a Lua file, run `:TSBufEnable highlight`, and test. The `@keyword.conditional` capture might highlight `if`/`else` as keywords, while `@function.name` highlights function names.

---

### Neovim Built-in Documentation

Neovim’s documentation is comprehensive for Tree-sitter. Access it via:
- `:help treesitter`: Overview of Tree-sitter integration.
- `:help treesitter-query`: Details on query syntax and Lua API.
- `:help treesitter-highlight`: Explains highlighting setup and capture groups.
- `:help treesitter-predicates`: Lists supported query predicates.
- `:help nvim-treesitter`: If using the `nvim-treesitter` plugin, covers configuration and commands like `:TSInstall` or `:TSUpdate`.
- `:help lua-treesitter`: Lua interface for Tree-sitter queries.

To search, use `:helpgrep treesitter` or `:help <topic>` (e.g., `:help treesitter-highlight-groups`).

---

### Online Resources

1. **Official Tree-sitter Documentation**:
   - [Tree-sitter Query Syntax](https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax): Covers the S-expression query language. Note that Neovim supports a subset of predicates (see `:help treesitter-predicates`).[](https://neovim.io/doc/user/treesitter.html)
   - Explains nodes, captures, and predicates like `(#match? @capture "pattern")`.

2. **nvim-treesitter GitHub**:
   - [nvim-treesitter Repository](https://github.com/nvim-treesitter/nvim-treesitter): Includes setup guides, query examples, and a gallery of highlighting improvements.[](https://github.com/nvim-treesitter/nvim-treesitter)
   - Check the `queries/` directory for example `.scm` files (e.g., `lua/highlights.scm`).

3. **Community Tutorials**:
   - [The Valuable Dev: Neovim and Tree-sitter](https://thevaluable.dev/treesitter-neovim/): A detailed guide with examples for syntax highlighting and query writing.[](https://thevaluable.dev/tree-sitter-neovim-overview/)
   - [Medium: Neovim 101 — Tree-sitter Usage](https://alpha2phi.medium.com/neovim-101-treesitter-usage-7b3e6303a6e3): Practical tips for queries and text objects.[](https://alpha2phi.medium.com/neovim-101-tree-sitter-usage-fa3e8bed921a)
   - [Jonas Hietala: Creating a Tree-sitter Grammar](https://www.jonashietala.se/blog/2024/03/18/lets_create_a_tree-sitter_grammar/): Includes query writing for custom languages.[](https://www.jonashietala.se/blog/2024/03/19/lets_create_a_tree-sitter_grammar/)

4. **Reddit and Stack Overflow**:
   - [r/neovim: How to Manually Source `.scm` Files](https://www.reddit.com/r/neovim/comments/10i7z1z/how_to_manually_source_the_treesitters_scm_file/): Discusses reloading queries.[](https://www.reddit.com/r/neovim/comments/10ifbkj/how_to_manually_source_the_treesitters_scm_file/)
   - [r/neovim: Hot Reload `highlights.scm`](https://www.reddit.com/r/neovim/comments/16e1y0g/how_to_hot_reload_highlightsscm_in_nvimtreesitter/): Tips for live query updates.[](https://www.reddit.com/r/neovim/comments/16e0l4o/how_to_hot_reload_highlightsscm_in_nvimtreesitter/)
   - [Stack Overflow: Treesitter and Syntax Folding](https://stackoverflow.com/questions/78037609/neovim-treesitter-and-syntax-folding): Covers related query issues.[](https://stackoverflow.com/questions/78077278/treesitter-and-syntax-folding)

5. **Neovim Discourse and Forums**:
   - Search [neovim.io](https://neovim.io) or the Neovim GitHub Discussions for community solutions.

---

### Tips for Learning `.scm` Syntax

- **Start Small**: Copy an existing `highlights.scm` from `nvim-treesitter` (e.g., for Lua or Python) and modify it.
- **Use `:TSPlaygroundToggle`**: Visualize the syntax tree to understand node types.
- **Experiment with Captures**: Test queries with simple captures like `@keyword` and link them to highlight groups.
- **Leverage `nvim-treesitter` Plugin**: Simplifies parser installation and query management. Install with:
  ```lua
  require('nvim-treesitter.configs').setup {
    highlight = { enable = true },
    ensure_installed = { "lua", "python" }, -- Add languages
  }
  ```
- **Check Colorscheme Compatibility**: Ensure your colorscheme defines Tree-sitter highlight groups (e.g., `@keyword`, `@function`). Use `:Inspect` to debug.

---

### Troubleshooting Common Issues

- **Highlighting Not Working**:
  - Verify parser installation: `:TSInstall <language>`.
  - Check filetype: `:set filetype=<language>`.
  - Ensure query file is in `runtimepath`: `:echo nvim_get_runtime_file('queries/<language>/*.scm', v:true)`.
- **Query Syntax Errors**:
  - Use `:checkhealth nvim-treesitter` to detect parser/query mismatches.
  - Validate queries with the Tree-sitter CLI: `tree-sitter parse <file>`.
- **Reloading Queries**:
  - See the reload steps above or check Reddit discussions for Lua-based solutions.[](https://www.reddit.com/r/neovim/comments/16e0l4o/how_to_hot_reload_highlightsscm_in_nvimtreesitter/)

---

### Summary

To work with Tree-sitter `.scm` files in Neovim:
1. Write S-expression queries in `~/.config/nvim/queries/<language>/<feature>.scm`.
2. Use captures like `@keyword` to tag nodes for highlighting or other features.
3. Test with `:TSBufEnable highlight` and debug with `:TSPlaygroundToggle` or `:Inspect`.
4. Reload queries using Lua commands or by reopening the file.
5. Refer to Neovim’s `:help treesitter` and online resources like Tree-sitter’s query documentation or `nvim-treesitter`’s GitHub.

For further exploration, Neovim’s built-in help (`:help treesitter-query`) and the `nvim-treesitter` repository are your best starting points. If you need specific examples or have a language in mind, let me know, and I can tailor a query for you!
</details>

<details>
<summary><h4>#!/usr/bin/env</h4></summary>

The `#!/usr/bin/env` shebang is a common Unix convention to make scripts portable by using the `env` command to locate the interpreter (e.g., `uv` in your case) in the user's `PATH`. Here’s where to find help on it:

1. **Man Pages**:
   - Run `man env` in your Terminal.app to see the manual for the `env` command, which explains its role in finding executables.

2. **Unix/Linux Documentation**:
   - Check online resources like [tldp.org](https://tldp.org/LDP/abs/html/abs-guide.html#PORTABILITYISSUES) (The Linux Documentation Project) for guides on shebang lines and `env` usage.
   - Search for “shebang env” on [unix.stackexchange.com](https://unix.stackexchange.com) for practical Q&A.

3. **MacOS-Specific**:
   - Apple’s developer docs ([developer.apple.com](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting)) cover shell scripting on macOS, including shebang portability.

4. **General Web**:
   - Articles on [stackoverflow.com](https://stackoverflow.com) (search “#!/usr/bin/env”) explain why `env` is preferred over hardcoding paths like `#!/usr/bin/python`.

The `#!/usr/bin/env -S uv run --script` uses `-S` to split arguments for `uv`, ensuring `uv run --script` runs the script with uv’s environment. If you need details on a specific aspect (e.g., `-S` flag, portability), just ask!

Use `#!/usr/bin/env` over an explicit shebang like `#!/usr/bin/zsh` when **portability** across systems is a priority. Here’s a quick breakdown:

### Use `#!/usr/bin/env` when:
1. **Interpreter Path Varies**:
   - Different systems (macOS, Linux distros, BSD) or setups (Homebrew, custom installs) may place interpreters like `zsh`, `python`, or `uv` in varying locations (e.g., `/usr/bin`, `/usr/local/bin`, `/opt/homebrew/bin`).
   - `env` searches the user’s `PATH`, ensuring the correct interpreter is found.

2. **User-Controlled Environments**:
   - Users may have custom installations (e.g., `zsh` via Homebrew on macOS in `/opt/homebrew/bin`).
   - `env` respects the user’s `PATH` precedence, avoiding errors from hardcoded paths.

3. **Virtual Environments or Tools**:
   - Tools like `uv`, `pyenv`, or `nvm` manage interpreter versions dynamically. `#!/usr/bin/env python3` ensures the active environment’s `python3` is used, not a system default.

4. **Cross-Platform Scripts**:
   - Scripts shared across teams or deployed on multiple OSes (e.g., CI/CD pipelines) benefit from `env` to avoid path assumptions.

### Use Explicit Shebang (`#!/usr/bin/zsh`) when:
1. **Controlled Environment**:
   - You control the system (e.g., a specific server) and know the interpreter’s exact path (e.g., `/usr/bin/zsh`).

2. **Performance**:
   - Explicit paths avoid the slight overhead of `env` searching the `PATH`. This is negligible for most scripts but matters in performance-critical cases.

3. **System Default Interpreter**:
   - You explicitly want the system’s default interpreter (e.g., `/usr/bin/zsh`) and not a user-installed version (e.g., `/opt/homebrew/bin/zsh`).

4. **Security Concerns**:
   - In rare cases, `env` could pick up a malicious interpreter if a user’s `PATH` is compromised. Explicit paths avoid this (though this is uncommon).

### Your Context (macOS, Homebrew, zsh):
- On your M1 MacBook Pro with Homebrew, `zsh` might be in `/bin/zsh` (system) or `/opt/homebrew/bin/zsh` (Homebrew). If you write scripts for your own setup, `#!/bin/zsh` is fine if you know the path.
- For scripts shared with others or used in varied environments (e.g., CI, other Macs), use `#!/usr/bin/env zsh` to ensure portability.
- For `uv` scripts (e.g., `#!/usr/bin/env -S uv run --script`), `env` is critical because `uv`’s path depends on how it was installed (e.g., via Homebrew, standalone).

### Quick Rule:
- **Default to `#!/usr/bin/env`** for portability unless you have a specific reason (controlled environment, performance, security) to hardcode the path.

If you need a code example or have a specific script case, let me know!

A **performance-critical case** for using an explicit shebang (e.g., `#!/usr/bin/zsh`) instead of `#!/usr/bin/env zsh` is when a script is executed **frequently** in a **high-throughput** or **low-latency** environment, where the overhead of `env` resolving the interpreter path (though small, typically microseconds) accumulates significantly. Here's an example:

### Example: Shell Script in a High-Frequency System Hook
**Scenario**: A `zsh` script is used as a Git hook (e.g., `pre-commit`) on a busy CI/CD server processing thousands of commits per minute. The script performs quick checks (e.g., linting) and must run as fast as possible to avoid slowing down the pipeline.

**Script**: `pre-commit`
```zsh
#!/usr/bin/zsh
# Check for trailing whitespace in staged files
git diff --cached --check
exit $?
```

**Why Explicit Shebang?**
- **Execution Frequency**: The `pre-commit` hook runs on every `git commit`, potentially thousands of times per minute in a large team’s CI system.
- **Overhead**: `#!/usr/bin/env zsh` invokes `env` to search the `PATH`, adding ~10-100 microseconds per invocation (depending on system and `PATH` length). For 10,000 commits, this could add 0.1–1 second of total delay.
- **Controlled Environment**: The CI server is a controlled environment where `/usr/bin/zsh` is guaranteed to exist (e.g., a specific Ubuntu version).
- **Cumulative Impact**: In a high-throughput pipeline, shaving microseconds per hook execution improves overall performance.

**Contrast with `env`**:
- If you used `#!/usr/bin/env zsh`, the `env` lookup would work fine but introduce unnecessary overhead in this specific case. Portability isn’t a concern since the server’s environment is fixed.

**Note**: This is a niche case. For most scripts (e.g., run occasionally or in varied environments), the `env` overhead is negligible, and portability is more important. On your M1 Mac with Homebrew, `env` is usually better unless you’re scripting something like a frequently triggered system utility.

If you want another example or a benchmark to test this, let me know!
</details>

<details>
<summary><h4>Shell Test Scripting</h4></summary>

Yes, there are standard and widely adopted approaches to setting up test harnesses for shell scripts, particularly for Bash or Zsh scripts like those generated by your `generate_script.sh`. These approaches focus on automation, repeatability, and integration with development workflows. Below, I’ll outline the most common methods, tools, and best practices for testing shell scripts, tailored to your context (M1 MacBook Pro, Homebrew, full dev setup). I’ll keep it concise and practical, as per your preference, and include examples relevant to your script generator.

### Standard Approaches for Shell Script Testing
1. **Dedicated Shell Testing Frameworks**:
   - Use frameworks designed for shell scripts to write and run tests with assertions.
   - Popular tools: `bats` (Bash Automated Testing System), `shunit2`, and `assert.sh`.

2. **Custom Test Scripts**:
   - Write custom Bash/Zsh test scripts using basic assertions (e.g., `if` conditions, `test`, or `[[ ]]`).
   - Suitable for simple projects but less maintainable than frameworks.

3. **Integration with CI/CD**:
   - Run tests in continuous integration pipelines (e.g., GitHub Actions, GitLab CI) for automated validation.
   - Combine with frameworks or custom scripts.

4. **Mocking and Stubbing**:
   - Mock external commands or dependencies to isolate script behavior.
   - Tools like `mock` or manual stubbing in Bash.

### Recommended Tool: Bats (Bash Automated Testing System)
`bats` is the most popular and standard tool for testing shell scripts due to its simplicity, active community, and integration with modern workflows. It’s well-suited for testing scripts generated by your `generate_script.sh`, as it supports testing command-line arguments, exit codes, and output.

#### Installation
On your M1 MacBook Pro with Homebrew:
```bash
brew install bats-core
```

#### Basic Structure
- Write test files with `.bats` extension.
- Use assertions like `assert_equal`, `assert_output`, and `assert_success`.
- Run tests with `bats <test_file_or_dir>`.

#### Example: Testing a Generated Script
Let’s create a test harness for the `process_data.sh` script from your earlier example, which has:
- Required args: `input_file`, `output_dir`
- Optional args: `-v` (verbose), `-m` (max lines)
- Shebang: `#!/usr/bin/env bash`

**Generated Script Recap** (`process_data.sh`):
```bash
#!/usr/bin/env bash
# process_data.sh: Process input data files
VERSION="1.0.0"
usage() { ... } # Prints usage with -h, --version
version() { echo "$VERSION"; exit 0; }
if [[ "$1" == "-h" ]]; then usage; fi
if [[ "$1" == "--version" ]]; then version; fi
VERBOSE="no"
MAX_LINES="1000"
while getopts "hvm:" opt; do
    case "$opt" in
        h) usage ;;
        v) VERBOSE="$OPTARG" ;;
        m) MAX_LINES="$OPTARG" ;;
        ?) usage ;;
    esac
done
shift $((OPTIND-1))
if [[ $# -lt 2 ]]; then echo "Error: Missing required positional inputs"; usage; fi
INPUT_FILE=$1
OUTPUT_DIR=$2
echo "Script running with the following inputs:"
echo "input_file: $INPUT_FILE"
echo "output_dir: $OUTPUT_DIR"
echo "-v: $VERBOSE"
echo "-m: $MAX_LINES"
```

**Test File** (`test_process_data.bats`):
```bash
#!/usr/bin/env bats

@test "shows help with -h" {
  run ./process_data.sh -h
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "Usage: process_data" ]]
  [[ "${lines[1]}" == "Options:" ]]
  [[ "${lines[2]}" == "  -h           Show this help message" ]]
}

@test "shows version with --version" {
  run ./process_data.sh --version
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "1.0.0" ]
}

@test "fails with missing required args" {
  run ./process_data.sh input.csv
  [ "$status" -ne 0 ]
  [[ "${lines[0]}" == "Error: Missing required positional inputs" ]]
}

@test "runs with required args only" {
  run ./process_data.sh input.csv /tmp/output
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "Script running with the following inputs:" ]]
  [[ "${lines[1]}" == "input_file: input.csv" ]]
  [[ "${lines[2]}" == "output_dir: /tmp/output" ]]
  [[ "${lines[3]}" == "-v: no" ]]
  [[ "${lines[4]}" == "-m: 1000" ]]
}

@test "handles optional args" {
  run ./process_data.sh input.csv /tmp/output -v yes -m 500
  [ "$status" -eq 0 ]
  [[ "${lines[3]}" == "-v: yes" ]]
  [[ "${lines[4]}" == "-m: 500" ]]
}
```

**Running Tests**:
```bash
bats test_process_data.bats
```
Output:
```
 ✓ shows help with -h
 ✓ shows version with --version
 ✓ fails with missing required args
 ✓ runs with required args only
 ✓ handles optional args

5 tests, 0 failures
```

#### Why Bats?
- **Readable Syntax**: Tests are written in a Bash-like style, easy for your background.
- **Assertions**: Built-in checks for exit status (`$status`), output (`${lines[@]}`), and more.
- **Setup/Teardown**: Use `setup` and `teardown` functions for test initialization (e.g., creating temp files).
- **CI Integration**: Works seamlessly with GitHub Actions or other CI systems.

### Alternative: shunit2
`shunit2` is another mature framework, slightly older but still effective.

#### Installation
```bash
brew install shunit2
```

#### Example Test
**Test File** (`test_process_data.sh`):
```bash
#!/bin/bash

testHelp() {
  output=$(./process_data.sh -h)
  assertEquals "Usage: process_data" "$(echo "$output" | head -n1)"
  assertTrue "echo '$output' | grep -q 'Show this help message'"
}

testVersion() {
  output=$(./process_data.sh --version)
  assertEquals "1.0.0" "$output"
}

testMissingArgs() {
  output=$(./process_data.sh input.csv 2>&1)
  assertFalse "Missing args should fail" $?
  assertTrue "echo '$output' | grep -q 'Missing required positional inputs'"
}

# Load shunit2
. /usr/local/bin/shunit2
```

**Running Tests**:
```bash
bash test_process_data.sh
```

#### Bats vs. shunit2
- **Bats**: More modern, cleaner syntax, better for new projects. Preferred for your use case.
- **shunit2**: More verbose, better for legacy projects or if you need fine-grained assertion control.

### Best Practices for Shell Script Test Harnesses
1. **Test Coverage**:
   - Test all CLI options (`-h`, `--version`, required/optional args).
   - Test edge cases (missing args, invalid inputs, special characters).
   - Test exit codes and error messages.

2. **Isolation**:
   - Use temporary directories/files to avoid polluting the environment.
   - Example in Bats:
     ```bash
     setup() {
       TEST_DIR=$(mktemp -d)
     }
     teardown() {
       rm -rf "$TEST_DIR"
     }
     ```

3. **Mocking**:
   - Mock external commands (e.g., `curl`, `grep`) to avoid real system calls.
   - Example: Create a fake `curl`:
     ```bash
     @test "mocks curl" {
       echo '#!/bin/bash\necho "Mock response"' > "$TEST_DIR/curl"
       chmod +x "$TEST_DIR/curl"
       PATH="$TEST_DIR:$PATH" run ./fetch_url.sh -r 5
       [ "$status" -eq 0 ]
     }
     ```

4. **CI Integration**:
   - Add a GitHub Actions workflow to run tests:
     ```yaml
     name: Test Shell Scripts
     on: [push, pull_request]
     jobs:
       test:
         runs-on: macos-latest
         steps:
           - uses: actions/checkout@v4
           - run: brew install bats-core
           - run: bats test/
     ```

5. **Directory Structure**:
   - Organize tests in a `test/` directory:
     ```
     project/
     ├── generate_script.sh
     ├── process_data.sh
     └── test/
         ├── test_process_data.bats
         └── test_fetch_url.bats
     ```

### Applying to Your `generate_script.sh`
Since your script generates other scripts, you can:
1. **Test the Generator**:
   - Write Bats tests to verify `generate_script.sh` produces correct scripts.
   - Example:
     ```bash
     @test "generates script with required arg" {
       run ./generate_script.sh -n test.sh -d "Test" -r "input|Input file"
       [ "$status" -eq 0 ]
       [ -f test.sh ]
       run bash test.sh input.txt
       [[ "${lines[1]}" == "input: input.txt" ]]
     }
     ```

2. **Test Generated Scripts**:
   - Generate scripts (e.g., `process_data.sh`) and write Bats tests for each, as shown above.
   - Automate test creation by extending `generate_script.sh` to output a `.bats` file alongside each script.

### Example for Your Workflow
To integrate testing into your project:
1. Create a `test/` directory.
2. Write `.bats` files for each generated script (e.g., `test_process_data.bats`).
3. Run tests locally:
   ```bash
   bats test/
   ```
4. Add a CI workflow (e.g., GitHub Actions) to run `bats` on push/PR.

### Notes
- **Bats is Standard**: It’s the go-to for most open-source shell projects (e.g., Homebrew, Docker CLI).
- **Minimal Setup**: Bats requires no complex dependencies, perfect for your Homebrew-based setup.
- **Mocking Needs**: If your generated scripts call external tools (e.g., `awk`, `sed`), use mocking to isolate tests.
- **Neovim Integration**: You can run `bats` from Neovim with a keybinding:
  ```vim
  nnoremap <leader>t :!bats test/<CR>
  ```

If you want a specific Bats test suite for `generate_script.sh` itself or a template for auto-generating `.bats` files alongside scripts, let me know!
</details>

<details>
<summary><h4>Gitea and GitHub CI/CD</h4></summary>

Integrating your shell scripts (like those generated by `generate_script.sh`) with CI/CD pipelines in **Gitea** and **GitHub** involves setting up automated testing and deployment workflows triggered by code changes. Below, I’ll explain how to integrate with both platforms, focusing on using **Gitea Actions** (Gitea’s built-in CI/CD) and **GitHub Actions**, and provide an example using a script generated by `generate_script.sh`. This is tailored to your M1 MacBook Pro setup with Homebrew, and I’ll keep it concise and practical per your preferences.

### Integration with Gitea CI/CD (Gitea Actions)
**Gitea Actions** is Gitea’s built-in CI/CD system, introduced in Gitea 1.19, and is highly compatible with GitHub Actions syntax. It uses **Gitea Runners** to execute workflows defined in YAML files.[](https://julius-roettgermann.de/post/hugo-cicd/)[](https://about.gitea.com/products/runner)

#### Setup Steps
1. **Install Gitea Runner**:
   - On your macOS system, use Docker (available via Homebrew) to run a Gitea Runner:
     ```bash
     brew install docker
     docker pull gitea/act_runner:latest
     docker run -d --name gitea-runner -v $(pwd)/data:/data -e GITEA_INSTANCE_URL=http://<your-gitea-url> -e GITEA_RUNNER_REGISTRATION_TOKEN=<your-token> gitea/act_runner:latest
     ```
   - Get `<your-token>` from Gitea’s admin dashboard: `Site Administration > Actions > Runners > Create new runner`.
   - Replace `<your-gitea-url>` with your Gitea instance (e.g., `http://localhost:3000`).

2. **Enable Actions for Repository**:
   - In your Gitea repository, go to `Settings > Actions` and enable Actions.

3. **Create Workflow File**:
   - Place a YAML file in `.gitea/workflows/<name>.yml` in your repository to define the CI/CD pipeline.

4. **Push to Gitea**:
   - Commit and push changes to trigger the pipeline. Gitea Actions will run the workflow on the runner.

#### Key Features
- **Compatibility**: Gitea Actions supports most GitHub Actions syntax, so you can reuse existing workflows.[](https://julius-roettgermann.de/post/hugo-cicd/)
- **Secrets**: Store sensitive data (e.g., API keys) in `Repository Settings > Secrets`.[](https://julius-roettgermann.de/post/hugo-cicd/)
- **Runners**: Run on Docker, VMs, or bare metal. Docker is simplest for your setup.[](https://about.gitea.com/products/runner)

### Integration with GitHub CI/CD (GitHub Actions)
**GitHub Actions** is GitHub’s CI/CD system, using YAML workflows triggered by events like pushes or pull requests.

#### Setup Steps
1. **Create Workflow File**:
   - Place a YAML file in `.github/workflows/<name>.yml` in your GitHub repository.

2. **Configure Runners**:
   - Use GitHub-hosted runners (e.g., `ubuntu-latest`) or self-hosted runners if you want to run on your Mac.
   - Self-hosted runner setup:
     ```bash
     brew install actions-runner
     ./config.sh --url https://github.com/<your-username>/<repo> --token <your-token>
     ./run.sh
     ```
     Get `<your-token>` from `Repository Settings > Actions > Runners > New self-hosted runner`.

3. **Push to GitHub**:
   - Commit and push to trigger the workflow.

#### Key Features
- **Hosted Runners**: GitHub provides Linux, macOS, and Windows runners, ideal for your macOS setup.
- **Marketplace**: Extensive actions (e.g., `actions/checkout`) simplify tasks.
- **Secrets**: Store sensitive data in `Repository Settings > Secrets and variables > Actions`.

### Synchronizing Gitea and GitHub
To use both Gitea and GitHub for CI/CD (e.g., Gitea for private repos, GitHub for public), set up repository mirroring:
- **In Gitea**:
  - Go to `Repository Settings > Git > Mirror Settings`.
  - Add a mirror to your GitHub repo (e.g., `https://github.com/<your-username>/<repo>`).
  - Use a GitHub Personal Access Token for authentication.[](https://calvin.me/self-hosted-git-cicd-use-cases/)
- **CI/CD Trigger**: A push to Gitea triggers its Actions pipeline and syncs to GitHub, which triggers GitHub Actions.[](https://calvin.me/self-hosted-git-cicd-use-cases/)
- **Alternative**: Use a Gitea webhook to trigger a GitHub Action, though mirroring is simpler.[](https://the-pi-guy.com/blog/gitea_cicd_pipeline_setup_with_github_actions/)

### Example: CI/CD for a Generated Script
Let’s use the `process_data.sh` script from your earlier example (generated by `generate_script.sh`) and set up CI/CD pipelines in both Gitea and GitHub. The script has:
- Required args: `input_file`, `output_dir`
- Optional args: `-v` (verbose), `-m` (max lines)
- Outputs input values for testing

**Generated Command**:
```bash
./generate_script.sh -s bash -n process_data.sh -d "Process input data files" -r "input_file|Input data file path" -r "output_dir|Output directory" -o "v|VERBOSE|Enable verbose logging|no" -o "m|MAX_LINES|Maximum lines to process|1000"
```

#### Test Harness
We’ll use `bats` (installed via `brew install bats-core`) to test `process_data.sh`. Create `test/test_process_data.bats`:
```bash
#!/usr/bin/env bats

@test "shows help with -h" {
  run ./process_data.sh -h
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "Usage: process_data" ]]
}

@test "shows version with --version" {
  run ./process_data.sh --version
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "1.0.0" ]
}

@test "fails with missing required args" {
  run ./process_data.sh input.csv
  [ "$status" -ne 0 ]
  [[ "${lines[0]}" == "Error: Missing required positional inputs" ]]
}

@test "runs with required args" {
  run ./process_data.sh input.csv /tmp/output
  [ "$status" -eq 0 ]
  [[ "${lines[1]}" == "input_file: input.csv" ]]
  [[ "${lines[2]}" == "output_dir: /tmp/output" ]]
}

@test "handles optional args" {
  run ./process_data.sh input.csv /tmp/output -v yes -m 500
  [ "$status" -eq 0 ]
  [[ "${lines[3]}" == "-v: yes" ]]
  [[ "${lines[4]}" == "-m: 500" ]]
}
```

#### Repository Structure
```
repo/
├── process_data.sh
├── test/
│   └── test_process_data.bats
├── .gitea/
│   └── workflows/
│       └── ci.yml
├── .github/
│   └── workflows/
│       └── ci.yml
```

#### Gitea Actions Workflow
Create `.gitea/workflows/ci.yml`:
```yaml
name: CI for process_data.sh
on:
  push:
    branches: [ main ]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      - name: Run Bats tests
        run: bats test/test_process_data.bats
```

**Setup**:
- Push to a Gitea repository with Actions enabled and a runner configured.
- The workflow installs `bats` and runs tests on every push to `main`.

#### GitHub Actions Workflow
Create `.github/workflows/ci.yml`:
```yaml
name: CI for process_data.sh
on:
  push:
    branches: [ main ]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      - name: Run Bats tests
        run: bats test/test_process_data.bats
```

**Setup**:
- Push to a GitHub repository.
- GitHub’s `ubuntu-latest` runner executes the workflow, installing `bats` and running tests.

#### Mirroring Setup
- In Gitea, mirror the repo to GitHub:
  - `Settings > Git > Mirror Settings > Add Mirror`.
  - Use `https://<github-username>:<PAT>@github.com/<your-username>/<repo>.git`.
- A push to Gitea runs Gitea Actions, syncs to GitHub, and triggers GitHub Actions.

### Testing the Pipeline
1. **Commit and Push**:
   ```bash
   git add .
   git commit -m "Add process_data.sh and tests"
   git push origin main
   ```
2. **Gitea**: Check `Repository > Actions` for the workflow run.
3. **GitHub**: Check `Repository > Actions` for the workflow run.
4. **Verify**: Both pipelines should pass all Bats tests, confirming `process_data.sh` works as expected.

### Notes
- **Bats Choice**: Bats is lightweight and standard for shell script testing, perfect for your generated scripts.[](https://calvin.me/self-hosted-git-cicd-use-cases/)
- **Gitea vs. GitHub Actions**: Gitea Actions is newer but compatible with GitHub Actions, making workflows portable. GitHub offers hosted runners, saving local resources.[](https://julius-roettgermann.de/post/hugo-cicd/)
- **Secrets**: If `process_data.sh` needs secrets (e.g., API keys), store them in Gitea/GitHub secrets and pass via environment variables.
- **Extending**: Add deployment steps (e.g., copy `process_data.sh` to a server) by extending the YAML workflows.
- **macOS Runners**: GitHub offers macOS runners, but Gitea runners on your Mac require Docker. Self-hosted GitHub runners are an option if you prefer local execution.

If you want a more complex example (e.g., testing `generate_script.sh` itself or adding deployment), or need help setting up Gitea/GitHub repos, let me know!
</details>

<details>
<summary><h4>Digital Signing Certificates</h4></summary>
### Safety of Using CAcert for Signing Digital Signatures

CAcert is a community-driven Certificate Authority (CA) that issues free digital certificates. While it can be used for signing digital signatures, its safety and suitability depend on several factors:

- **Trustworthiness**: CAcert certificates are not included in the default trust stores of major operating systems (e.g., macOS, Windows) or browsers. This means that signatures created with CAcert certificates may not be inherently trusted by recipients unless they manually add CAcert’s root certificate to their trust store. For personal or internal use, this might be acceptable, but for legal or professional purposes, a certificate from a widely trusted CA (e.g., DigiCert, Sectigo, or Adobe Approved Trust List members) is preferred to ensure universal validation.

- **Security**: CAcert has faced criticism in the past for security practices and audit issues, which led to its root certificates being excluded from major trust stores. While it can still be used, you should evaluate the risk of relying on a less rigorously audited CA, especially for sensitive documents. Ensure your private key is securely stored and protected.

- **Use Case**: For non-critical, personal, or testing purposes, CAcert can be safe enough if you understand its limitations. For legally binding signatures or high-stakes transactions, opt for a certificate from a trusted CA that complies with standards like PAdES (PDF Advanced Electronic Signatures) or eIDAS (EU regulation for electronic signatures).

- **Validation**: Signatures created with CAcert certificates may show warnings or be marked as untrusted in PDF readers like Adobe Acrobat unless the recipient trusts CAcert’s root certificate. This could undermine the document’s credibility.

**Recommendation**: CAcert is reasonably safe for informal or internal use but not ideal for professional or legally binding signatures due to limited trust and recognition. If you need a free alternative, consider creating a self-signed certificate for testing (though it has similar trust issues) or obtaining a certificate from a trusted CA for production use.

### Best Method for Signing a PDF on macOS Using the Command Line

For signing PDFs on macOS using the command line, the most robust and flexible tool is `pyhanko`, a Python-based CLI tool that supports certificate-based digital signatures. It’s well-documented, supports PAdES-compliant signatures, and works with certificates stored in macOS Keychain or as files. Below is the step-by-step method:

#### Prerequisites
1. **Install Python and pyhanko**:
   Ensure Python 3 is installed (use Homebrew: `brew install python3` if needed).
   Install `pyhanko` via pip:
   ```bash
   pip install pyhanko
   ```

2. **Obtain a Digital Certificate**:
   - **CAcert**: If using CAcert, request a certificate from their website and import it into macOS Keychain (`.p12` or `.pem` format). Use Keychain Access to import: `File > Import Items`, select the certificate file, and enter the password provided by CAcert.
   - **Self-Signed (for Testing)**: Create a self-signed certificate using Keychain Access:
     - Open Keychain Access.
     - Go to `Keychain Access > Certificate Assistant > Create a Certificate`.
     - Choose “Self Signed Root”, set the certificate type to “Code Signing” or “S/MIME”, and save it to the login keychain.
   - **Trusted CA**: Obtain a certificate from a trusted CA (e.g., DigiCert, Sectigo) and import it similarly.

3. **Install OpenSSL (if needed)**:
   For handling certificate files outside Keychain, ensure OpenSSL is installed:
   ```bash
   brew install openssl
   ```

#### Signing a PDF Using `pyhanko`
`pyhanko` supports signing with certificates stored in Keychain or as PKCS#12 files. Here’s how to sign a PDF:

1. **Prepare the Certificate**:
   - If the certificate is in Keychain, note its Common Name (CN) or SHA-1 fingerprint (viewable in Keychain Access).
   - If using a `.p12` file, ensure you have the file and its password.

2. **Basic Command to Sign**:
   Use the following command to sign a PDF with a Keychain-stored certificate:
   ```bash
   pyhanko sign addedsig --field Sig1 \
   --keychain-cert-label "Your Certificate CN" \
   input.pdf output.pdf
   ```
   - Replace `"Your Certificate CN"` with the certificate’s Common Name or SHA-1 fingerprint.
   - `Sig1` is the name of the signature field (can be custom).
   - `input.pdf` is the unsigned PDF; `output.pdf` is the signed output.

   If using a `.p12` file instead:
   ```bash
   pyhanko sign addedsig --field Sig1 \
   --p12 "path/to/cert.p12" --p12-passwd "your_password" \
   input.pdf output.pdf
   ```

3. **Add a Timestamp (Optional but Recommended)**:
   To enhance signature validity, include a timestamp from a trusted timestamp authority (TSA):
   ```bash
   pyhanko sign addedsig --field Sig1 \
   --keychain-cert-label "Your Certificate CN" \
   --timestamp-url http://tsa.example.com/tsa \
   input.pdf output.pdf
   ```
   - Replace `http://tsa.example.com/tsa` with a valid TSA URL (e.g., `http://timestamp.digicert.com` or a free TSA like `http://time.certum.pl`).
   - Timestamps ensure long-term validation (PAdES-LTV compliance).

4. **Customize Signature Appearance (Optional)**:
   To add a visible signature with custom text or appearance:
   ```bash
   pyhanko sign addedsig --field Sig1/visible \
   --keychain-cert-label "Your Certificate CN" \
   --timestamp-url http://tsa.example.com/tsa \
   --appearance-text "Signed by Your Name" \
   input.pdf output.pdf
   ```
   - The `/visible` flag makes the signature visible on the PDF.
   - `--appearance-text` sets the text displayed in the signature field.

5. **Verify the Signature**:
   After signing, verify the output PDF:
   ```bash
   pyhanko validate output.pdf
   ```
   This checks the signature’s integrity and trust status.

#### Notes
- **Keychain Access**: When running the command, macOS may prompt for permission to access the private key in Keychain. Click “Allow” or “Always Allow” to avoid repeated prompts.
- **PAdES Compliance**: `pyhanko` supports PAdES standards (Part 2, 3, or 4) for legally binding signatures. Use `--pades` for explicit PAdES compliance:
  ```bash
  pyhanko sign addedsig --pades --field Sig1 ...
  ```
- **Dependencies**: Ensure `pyhanko` dependencies (e.g., `cryptography`, `pypdf`) are installed. Run `pip install pyhanko[all]` to include optional features like PKCS#11 support.
- **Alternative Tools**: If `pyhanko` doesn’t suit your needs, consider `openssl` with `pdfsign` (less user-friendly) or commercial tools like Adobe Acrobat Pro (GUI-based, not CLI).

#### Example Full Command
Sign a PDF with a CAcert certificate in Keychain, including a timestamp and visible signature:
```bash
pyhanko sign addedsig --field Sig1/visible \
--keychain-cert-label "CAcert User Certificate" \
--timestamp-url http://time.certum.pl \
--appearance-text "Signed by John Doe" \
--pades \
input.pdf output.pdf
```

### Why `pyhanko`?
- **CLI-Friendly**: Designed for command-line use, ideal for automation.
- **macOS Integration**: Seamlessly works with Keychain-stored certificates.
- **PAdES Support**: Ensures compliance with advanced signature standards.
- **Active Development**: Regularly updated with good documentation (https://pyhanko.readthedocs.io/en/latest/cli-guide/signing.html).

### Security Tips
- **Protect Private Keys**: Store certificates securely and never share private keys.
- **Use Trusted TSAs**: For timestamps, use reputable TSAs to ensure long-term signature validity.
- **Validate Signatures**: Always verify signatures after signing to confirm integrity.
- **Backup Certificates**: Export your certificate from Keychain (as `.p12`) and store it securely in case of system failure.

If you need further details or run into issues, let me know![](https://www.reddit.com/r/MacOS/comments/x0jlvj/sign_pdf_using_certificate/)
</details>
