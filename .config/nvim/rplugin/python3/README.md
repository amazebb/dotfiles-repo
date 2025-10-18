## Neovim remote plugins using Python

> [!WARNING] 
> The actual python code is experimental, most does not work and not finished!! 
> It was just a simple test of the pynvim interface

## Setting up remote Python plugin

Python plugins need to go into a folder `rplugins/python3` that is on the runtimepath such as, `~/.config/nvim/rplugin/python3`

Re-register the plugins by running

```bash
rm ~/.local/share/nvim/rplugin.vim
nvim
:UpdateRemotePlugins
```

The `rplugin.vim` file should look like the following for our single LLMChat python plugin

```vim
" perl plugins


" node plugins


" python3 plugins
call remote#host#RegisterPlugin('python3', '~/.config/nvim/rplugin/python3/llm_chat.py', [
      \ {'sync': v:true, 'name': 'LLMCreateChatBuffer', 'type': 'command', 'opts': {}},
      \ {'sync': v:true, 'name': 'LLMChatSend', 'type': 'command', 'opts': {}},
      \ {'sync': v:true, 'name': 'LLMSetModel', 'type': 'command', 'opts': {'nargs': '1'}},
     \ ])


" ruby plugins

```

Use Neovim's Lua API to extract buffer content, send it via HTTP to xAI's Grok API for code modifications, then apply the response to the buffer.

## Steps
Extract buffer lines with `vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)`, where `bufnr` is `0` for current or a specified buffer number.  
Send content as prompt payload to xAI API endpoint using `curl` via `vim.system` (e.g., format prompt as "Modify this code: [content]").  
Parse API response JSON for modified code.  
Replace buffer with `vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)`.  

Refer to https://x.ai/api for API details, authentication, and endpoints.


Use https://api.x.ai/v1/chat/completions endpoint with OpenAI-compatible format. Authenticate via API key. Model: grok-4. Prompt example: "Modify this code: [buffer content]".

## Lua MVP in Neovim
Define command to send current buffer to API and replace with modified code.

```lua
-- Define function to modify buffer via xAI API
local function modify_buffer()
  local bufnr = vim.api.nvim_get_current_buf()  -- Get current buffer number
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)  -- Extract lines
  local code = table.concat(lines, "\n")  -- Join into string

  local api_key = os.getenv("XAI_API_KEY")  -- Load API key from env
  if not api_key then
    vim.notify("XAI_API_KEY not set", vim.log.levels.ERROR)
    return
  end

  local prompt = "Modify this code to add error handling: " .. code  -- Example prompt

  -- JSON payload
  local payload = vim.json.encode({
    model = "grok-4",
    messages = {{role = "user", content = prompt}},
    max_tokens = 1000,
    temperature = 0.2,
  })

  -- Curl command via vim.system
  local cmd = {
    "curl", "-s", "-X", "POST",
    "https://api.x.ai/v1/chat/completions",
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer " .. api_key,
    "-d", payload
  }

  local result = vim.system(cmd):wait()
  if result.code ~= 0 then
    vim.notify("API request failed: " .. result.stderr, vim.log.levels.ERROR)
    return
  end

  -- Parse JSON response
  local response = vim.json.decode(result.stdout)
  local modified_code = response.choices[1].message.content  -- Extract completion

  -- Split into lines and replace buffer
  local new_lines = vim.split(modified_code, "\n", {trimempty = true})
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
end

-- Create user command
vim.api.nvim_create_user_command("ModifyCode", modify_buffer, {})
```

Run `:ModifyCode` on buffer. Assumes XAI_API_KEY env var.

## Python with pynvim
Yes, create external Python plugin using pynvim to access buffers, send requests via openai library, update buffer.

Install: `uv pip install pynvim openai`.

Example plugin script (`~/.local/share/nvim/site/plugin/xai_modify.py`):

```python
import pynvim
from openai import OpenAI
import os

@pynvim.plugin
class XAIModify(object):
    def __init__(self, vim):
        self.vim = vim
        self.client = OpenAI(
            api_key=os.getenv("XAI_API_KEY"),
            base_url="https://api.x.ai/v1",
        )

    @pynvim.command('ModifyCodePython', nargs='*', sync=True)
    def modify_code(self, args):
        bufnr = self.vim.current.buffer.number if not args else int(args[0])
        lines = self.vim.api.buf_get_lines(bufnr, 0, -1, False)
        code = '\n'.join(lines)

        prompt = f"Modify this code to add error handling: {code}"

        response = self.client.chat.completions.create(
            model="grok-4",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=1000,
            temperature=0.2,
        )

        modified_code = response.choices[0].message.content

        new_lines = modified_code.split('\n')
        self.vim.api.buf_set_lines(bufnr, 0, -1, False, new_lines)
```

Source in init.lua: `vim.cmd('runtime plugin/xai_modify.py')`. Run `:ModifyCodePython` or `:ModifyCodePython <bufnr>`.

Lua method preferred for native integration in Neovim.

## Performance
Lua outperforms Python in Neovim due to embedded LuaJIT, avoiding Python host overhead like IPC. Benchmarks show LuaJIT 10-100x faster than equivalent scripting. Python suitable if prioritizing Python skill development.

