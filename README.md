## Install launch daemon for Llama.cpp

```bash
./install-llama-server.sh /path/to/llama-server /path/to/model <label>
```

e.g.

```bash
### Qwen 2.5 32b Instruct

./install-llama-server.sh $HOME/.bin/llama.cpp/llama-server $HOME/.cache/lm-studio/models/bartowski/Qwen2.5-32B-Instruct-GGUF/Qwen2.5-32B-Instruct-Q4_K_L.gguf qwen2.5-32b 3456

### Qwen 2.5 Coder 32b Instruct

./install-llama-server.sh $HOME/.bin/llama.cpp/llama-server $HOME/.cache/lm-studio/models/Qwen/Qwen2.5-Coder-32B-Instruct-GGUF/qwen2.5-coder-32b-instruct-q4_0.gguf  qwen2.5-coder-32b 3457

### code completion

./install-llama-server.sh $HOME/.bin/llama.cpp/llama-server $HOME/.cache/lm-studio/models/prithivMLmods/Qwen2.5-Coder-7B-GGUF/Qwen2.5-Coder-7B.Q4_K_M.gguf  qwen2.5-coder-3b 3458

./install-llama-server.sh $HOME/.bin/llama.cpp/llama-server $HOME/.cache/lm-studio/models/second-state/StarCoder2-7B-GGUF/starcoder2-7b-Q4_0.gguf starcoder2-7b 3458

./install-llama-server.sh $HOME/.bin/llama.cpp/llama-server $HOME/.cache/lm-studio/models/second-state/StarCoder2-3B-GGUF/starcoder2-3b-Q4_0.gguf starcoder2-3b 3458
```

## Install launch daemon for proxy

```bash
./install-llama-proxy.sh <docker-binary-path> <label> <upstream-port> <proxy-port>
```

e.g.

```bash
### Qwen 2.5 32b Instruct

./install-llama-proxy.sh $HOME/.local/bin/docker qwen2.5-32b 3456 5678

### Qwen 2.5 Coder 32b Instruct

./install-llama-proxy.sh $HOME/.local/bin/docker qwen2.5-coder-32b 3457 5679
```
