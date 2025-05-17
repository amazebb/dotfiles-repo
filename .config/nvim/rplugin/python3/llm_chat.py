import pynvim
import requests


@pynvim.plugin
class LLMChat(object):
    def __init__(self, nvim):
        self.nvim = nvim
        self.server_url = "http://localhost:8080/v1/chat/completions"
        self.model = "mlx-community/Qwen3-4B-4bit"

    @pynvim.command("LLMCreateChatBuffer", sync=True)
    def create_chat_buffer(self):
        self.nvim.command("enew")
        self.nvim.command("set filetype=markdown")
        self.nvim.command("file llm_chat")
        self.nvim.command("setlocal buftype=nofile noswapfile")
        # self.nvim.command("nnoremap <buffer> <CR> :LLMChatSend<CR>")
        # self.nvim.command("nnoremap <buffer> <cr> :silent LLMChatSend<cr>")
        self.nvim.api.nvim_buf_set_keymap(
            0, "n", "<cr>", ":call LLMChatSend()<cr>", {"silent": True}
        )

    @pynvim.command("LLMChatSend", sync=True)
    def send_message(self):
        buffer = self.nvim.current.buffer
        cursor = self.nvim.current.window.cursor[0]
        prompt_lines = buffer[:cursor]
        prompt = "\n".join(prompt_lines).strip()
        if not prompt:
            return

        payload = {
            "messages": [{"role": "user", "content": prompt}],
            "model": self.model,
            "temperature": 0.7,
        }
        headers = {"Content-Type": "application/json"}

        def update_buffer(response_text):
            lines = response_text.splitlines()
            buffer.append(["", "```"] + lines + ["```"])
            self.nvim.command("normal! G")

        try:
            response = requests.post(self.server_url, json=payload, headers=headers)
            response.raise_for_status()
            response_text = response.json()["choices"][0]["message"]["content"]
            update_buffer(response_text)
        except requests.RequestException as e:
            self.nvim.command(f'echo "Server error: {str(e)}"')

    @pynvim.command("LLMSetModel", nargs="1", sync=True)
    def set_model(self, args):
        self.model = args[0]
        self.nvim.command(f'echo "Model set to {self.model}"')
