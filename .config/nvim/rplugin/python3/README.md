## Neovim remote plugins using Python

!> [!WARNING] This code is experimental, does not work and not finished!! 

## Setting up remote Python plugin

Python plugins need to go into a folder rplugins/python3 that is on the runtimepath `~/.config/nvim/rplugin/python3`

Re-register the plugins by running

```bash
rm ~/.local/share/nvim/rplugin.vim
nvim
:UpdateRemotePlugins
```

The `rplugin.vim` file should like the following for our single LLMChat python plugin

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


