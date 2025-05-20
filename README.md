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

This list was created by running **list-scripts**

```
check-scripts.sh     bash     Runs shellcheck on .sh scripts in a given folder to identify issues
compare-folders.sh   bash     Compare files in different folders
data-backup.sh       bash     Backs up folders to SPARSE image bundle in iCloud
disk-useage.sh       dash     Disk usage analyzer with configurable options
dotfiles.sh          bash     Used for adding dotfiles in home directory to git bare repo
gitea-cli.sh         dash     Manage Gitea with start, stop, and log options
info2vim.sh          dash     Launch GNU info for a coreutils command and pipe to Neovim
list-scripts.sh      dash     List all scripts in ~/.local/bin with a description
llamaup.sh           dash     Update all Ollama models
n.sh                 dash     Launch nnn and with auto preview if from tmux
new-script.sh        bash     A script to generate a new shell script template with specified options
preview_cmd.sh       dash     Preview files and directories function executed by nnn
print-ascii.sh       bash     Print the ASCII codes given a range of numbers
print-colors.sh      bash     Display all 256 ANSI colors in the terminal
```
</details>

<details>
<summary><h4>Zsh color quirks</h4></summary>
There is a quirk with setting colors on MacOS (15.4.1) and zsh (5.9 arm64-apple-darwin24.0) 

This is irregardless of the ANSI colors setup in Terminal for Normal and Bright.

For instance if we try to set **%F{blue}** and **%K{blue}** they will look different, even though there RGB values 
in the Terminal.app settings palette may have been set to identical colors. 

No amount of using the expansions with named, 'blue', or numeric values, 004, 
or trying to reset the colors using %k or %f seems to fix it.

The fix is as thus, instead of using %k to reset the background, we need to use a number that is out of range of Terminals 0-255 colors,
and to use it with an escape sequence.

The trick is to use the [escape sequence](https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background/446604#446604) **\e[48;5;256m**

So instead of matching the right trianlge foreground color to the background of previous space character
```zsh
print -P "%K{blue} %k%F{blue}\uE0B0"
```

We do the following:

```zsh
print -P "%K{blue} \e[48;5;256m%F{blue}\uE0B0"
```

Here is [Grok](https://grok.com/share/bGVnYWN5_44f1eb29-e093-436e-8b53-7a0206ae3725) just absolutely struggling with this on 4/17/25
</details>

## Neovim Tips:
Format all Lua files under current folder recursively:

```vim
:args **/*.lua
:argdo lua vim.lsp.buf.format()
```

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
