#!/bin/bash

usage() {
    echo "Usage: $0 <docker-binary-path> <label> <upstream-port> <proxy-port>"
    exit 1
}

if [ "$#" -ne 4 ]; then
    usage
fi

DOCKER_BINARY=$1
LABEL=$2
UPSTREAM_PORT=$3
PROXY_PORT=$4

if [ ! -x "$DOCKER_BINARY" ]; then
    echo "Error: Docker binary not found or not executable: $DOCKER_BINARY"
    exit 1
fi

PLIST_PATH="/Library/LaunchDaemons/com.llama-proxy.${LABEL}.plist"
PLIST_TEMP=$(mktemp)

cat <<EOF | sudo tee "$PLIST_TEMP" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.llama-proxy.${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${DOCKER_BINARY}</string>
        <string>run</string>
        <string>--name</string>
        <string>openai-prompt-cache-proxy-${LABEL}</string>
        <string>--rm</string>
        <string>-e</string>
        <string>UPSTREAM_BASE_URL=http://host.docker.internal:${UPSTREAM_PORT}</string>
        <string>-p</string>
        <string>${PROXY_PORT}:5678</string>
        <string>vitobotta/openai-prompt-cache-proxy:v7</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/com.llama-proxy.${LABEL}.out.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/com.llama-proxy.${LABEL}.err.log</string>
</dict>
</plist>
EOF

cleanup() {
    rm -f "$PLIST_TEMP"
    echo "Temporary files cleaned up."
}

trap cleanup EXIT

sudo tee "$PLIST_PATH" < "$PLIST_TEMP" > /dev/null || { echo "Failed to write plist file"; exit 1; }

sudo chown root:wheel "$PLIST_PATH" || { echo "Failed to change owner of plist file"; exit 1; }
sudo chmod 644 "$PLIST_PATH" || { echo "Failed to change permissions of plist file"; exit 1; }

sudo launchctl load "$PLIST_PATH" || { echo "Failed to load plist file"; exit 1; }

echo "Daemon created and loaded with label: com.llama-proxy.${LABEL}"

echo "Checking if the daemon is running..."
sudo launchctl list | grep "com.llama-proxy.${LABEL}"
