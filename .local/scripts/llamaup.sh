#!/bin/dash
# Update all Ollama models

ollama list | awk 'NR>1 {print $1}' | xargs -I {} zsh -c 'echo "Pulling {}"; ollama pull "{}"'
