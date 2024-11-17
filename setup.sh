#!/bin/bash

usage() {
    echo "Usage: $0 install|uninstall|load|unload --type <server|proxy> --binary-path <path> --label <label> --port <port> [--model-path <path>] [--upstream-port <port>] [--keep-model-in-memory <true|false>] [--context-length 4096]"
    exit 1
}

COMMAND=$1
shift

TYPE=
BINARY_PATH=
MODEL_PATH=
LABEL=
PORT=
UPSTREAM_PORT=
MLOCK="true"
CONTEXT_LENGTH=4096

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --binary-path) BINARY_PATH="$2"; shift 2 ;;
        --model-path) MODEL_PATH="$2"; shift 2 ;;
        --label) LABEL="$2"; shift 2 ;;
        --port) PORT="$2"; shift 2 ;;
        --upstream-port) UPSTREAM_PORT="$2"; shift 2 ;;
        --keep-model-in-memory) MLOCK="$2"; shift 2 ;;
        --context-length) CONTEXT_LENGTH="$2"; shift 2 ;;
        *) usage ;;
    esac
done

PLIST_PATH="$HOME/Library/LaunchAgents/com.llama-${TYPE}.${LABEL}.plist"
PLIST_TEMP=$(mktemp)

if [[ "$COMMAND" == "install" ]]; then
    if [[ -z "$TYPE" || -z "$BINARY_PATH" || -z "$LABEL" || -z "$PORT" ]]; then
        usage
    fi

    if [[ "$TYPE" != "server" && "$TYPE" != "proxy" ]]; then
        echo "Error: Type must be either 'server' or 'proxy'"
        usage
    fi

    if [[ ! -x "$BINARY_PATH" ]]; then
        echo "Error: Binary path is not executable"
        exit 1
    fi

    if [[ "$TYPE" == "server" && -z "$MODEL_PATH" ]]; then
        echo "Error: Model path is required for server type"
        usage
    fi

    if [[ "$TYPE" == "proxy" && -z "$UPSTREAM_PORT" ]]; then
        echo "Error: Upstream port is required for proxy type"
        usage
    fi

    if [[ "$TYPE" == "server" ]]; then
        cat > "$PLIST_TEMP" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.llama-server.${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${BINARY_PATH}</string>
        <string>-m</string>
        <string>${MODEL_PATH}</string>
        <string>--threads</string>
        <string>14</string>
        <string>--threads-batch</string>
        <string>2</string>
        <string>--ctx-size</string>
        <string>${CONTEXT_LENGTH}</string>
        <string>--n-predict</string>
        <string>4096</string>
        <string>--parallel</string>
        <string>4</string>
        <string>--cont-batching</string>
        <string>--flash-attn</string>
EOF
        if [[ "$MLOCK" == "true" ]]; then
            echo "        <string>--mlock</string>" >> "$PLIST_TEMP"
        fi

        cat >> "$PLIST_TEMP" <<EOF
        <string>--n-gpu-layers</string>
        <string>1000</string>
        <string>--batch-size</string>
        <string>224</string>
        <string>--host</string>
        <string>0.0.0.0</string>
        <string>--port</string>
        <string>${PORT}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/log/com.llama-server.${LABEL}.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/log/com.llama-server.${LABEL}.err.log</string>
</dict>
</plist>
EOF
    elif [[ "$TYPE" == "proxy" ]]; then
        cat > "$PLIST_TEMP" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.llama-proxy.${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${BINARY_PATH}</string>
        <string>run</string>
        <string>--name</string>
        <string>openai-prompt-cache-proxy-${LABEL}</string>
        <string>--rm</string>
        <string>-e</string>
        <string>UPSTREAM_BASE_URL=http://host.docker.internal:${UPSTREAM_PORT}</string>
        <string>-p</string>
        <string>${PORT}:5678</string>
        <string>vitobotta/openai-prompt-cache-proxy:v10</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/log/com.llama-proxy.${LABEL}.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/log/com.llama-proxy.${LABEL}.err.log</string>
</dict>
</plist>
EOF
    fi

    cleanup() {
        rm -f "$PLIST_TEMP"
    }
    trap cleanup EXIT

    mkdir -p /tmp/log

    touch "/tmp/log/com.llama-${TYPE}.${LABEL}.out.log"
    touch "/tmp/log/com.llama-${TYPE}.${LABEL}.err.log"

    cp "$PLIST_TEMP" "$PLIST_PATH"
    launchctl load "$PLIST_PATH"

elif [[ "$COMMAND" == "uninstall" ]]; then
    launchctl unload "$PLIST_PATH"
    rm -f "$PLIST_PATH"
    rm -f "/tmp/log/com.llama-${TYPE}.${LABEL}.out.log"
    rm -f "/tmp/log/com.llama-${TYPE}.${LABEL}.err.log"

elif [[ "$COMMAND" == "load" ]]; then
    launchctl load "$PLIST_PATH"

elif [[ "$COMMAND" == "unload" ]]; then
    launchctl unload "$PLIST_PATH"

else
    usage
fi

cleanup() {
    rm -f "$PLIST_TEMP"
}
trap cleanup EXIT
