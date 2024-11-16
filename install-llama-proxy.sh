#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <docker-binary-path> <label> <upstream-port> <proxy-port>"
    exit 1
fi

DOCKER_BINARY=$1
LABEL=$2
UPSTREAM_PORT=$3
PROXY_PORT=$4

PLIST_PATH="/Library/LaunchDaemons/com.llama-proxy.${LABEL}.plist"

PLIST_CONTENT="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
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
</plist>"

echo "${PLIST_CONTENT}" | sudo tee "${PLIST_PATH}" > /dev/null

sudo chown root:wheel "${PLIST_PATH}"
sudo chmod 644 "${PLIST_PATH}"

sudo launchctl load "${PLIST_PATH}"

echo "Daemon created and loaded with label: com.llama-proxy.${LABEL}"

echo "Checking if the daemon is running..."
sudo launchctl list | grep "com.llama-proxy.${LABEL}"
