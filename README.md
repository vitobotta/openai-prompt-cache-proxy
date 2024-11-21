## Qwen 2.5 32b Instruct

### Install

```bash
./setup.sh install --type server --binary-path $HOME/.bin/llama.cpp/llama-server --label qwen2.5-32b --port 3456 --model-path $HOME/.cache/lm-studio/models/bartowski/Qwen2.5-32B-Instruct-GGUF/Qwen2.5-32B-Instruct-Q4_K_L.gguf --keep-model-in-memory false --context-length 8192

./setup.sh install --type proxy --binary-path $HOME/.local/bin/docker --label qwen2.5-32b --port 5678 --upstream-port 3456
```

### Uninstall

```bash
./setup.sh uninstall --type server --label qwen2.5-32b
./setup.sh uninstall --type proxy --label qwen2.5-32b
```

### Unload

```bash
./setup.sh unload --type server --label qwen2.5-32b
./setup.sh unload --type proxy --label qwen2.5-32b
```

### Load

```bash
./setup.sh load --type server --label qwen2.5-32b
./setup.sh load --type proxy --label qwen2.5-32b
```

---

## Qwen 2.5 Coder 32b Instruct

### Install

```bash
./setup.sh install --type server --binary-path $HOME/.bin/llama.cpp/llama-server --label qwen2.5-coder-32b --port 3457 --model-path $HOME/.cache/lm-studio/models/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF/Qwen2.5-Coder-32B-Instruct-Q4_K_L.gguf  --keep-model-in-memory false --context-length 8192

./setup.sh install --type proxy --binary-path $HOME/.local/bin/docker --label qwen2.5-coder-32b --port 5679 --upstream-port 3457
```

### Uninstall

```bash
./setup.sh uninstall --type server --label qwen2.5-coder-32b
./setup.sh uninstall --type proxy --label qwen2.5-coder-32b
```

### Unload

```bash
./setup.sh unload --type server --label qwen2.5-coder-32b
./setup.sh unload --type proxy --label qwen2.5-coder-32b
```

### Load

```bash
./setup.sh load --type server --label qwen2.5-coder-32b
./setup.sh load --type proxy --label qwen2.5-coder-32b
```

---

## Qwen 2.5 Coder 7b  (code completions)

### Install

```bash
./setup.sh install --type server --binary-path $HOME/.bin/llama.cpp/llama-server --label qwen2.5-coder-7b --port 3458 --model-path $HOME/.cache/lm-studio/models/QuantFactory/Qwen2.5-Coder-7B-GGUF/Qwen2.5-Coder-7B.Q4_0.gguf --keep-model-in-memory true
```

### Uninstall

```bash
./setup.sh uninstall --type server --label qwen2.5-coder-7b
```

### Unload

```bash
./setup.sh unload --type server --label qwen2.5-coder-7b
```

### Load

```bash
./setup.sh load --type server --label qwen2.5-coder-7b
```


