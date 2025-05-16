## Huggingface Examples

### List models on HuggingFace

Return all the mlx-community models sorted by date descending and name ascending
```bash
uv run list_mlx_models.py | fzf
```

### Install a model

Let us download the Qwen3-4B-4bit model, this will be downloaded to `~/.cache/huggingface/hub/models--mlx-community--Qwen3-4B-4bit`
```bash
uv run python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='mlx-community/Qwen3-4B-4bit')"
```

To change download location add the ```local_dir``` as part of the snapshot_download command.

NOTE: The `/huggingface/xet` folder is a temporary cache folder that can be deleted


### Run the model from virtual env

Ensure venv is activated ```source .venv/bin/activate```
```bash
mlx_lm.generate --model mlx-community/Qwen3-4B-4bit --prompt "How tall is Mt Everest?"
```

We can also check to see its loaded correctly by running a simple import
```bash
uv run python -c "from mlx_lm import load; model, tokenizer = load('mlx-community/Qwen3-4B-4bit')"
```

### Run as server

Start the server on default localhost port 8080. If the model doesnt exists in the local cache it will be downloaded
```bash
mlx_lm.server --trust-remote-code --model mlx-community/Qwen3-4B-4bit
```

Get a list of the models being served
```bash
curl localhost:8080/v1/models -H "Content-Type: application/json"
```
