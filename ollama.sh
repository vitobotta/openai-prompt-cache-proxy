#!/bin/bash

usage() {
    echo "Usage: $0 install|uninstall|load|unload"
    exit 1
}

COMMAND=$1
shift

PLIST_PATH="$HOME/Library/LaunchAgents/com.ollama.plist"
PLIST_TEMP=$(mktemp)

if [[ "$COMMAND" == "install" ]]; then
  cat > "$PLIST_TEMP" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/vito/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0</string>
        <key>OLLAMA_MAX_LOADED_MODELS</key>
        <string>10</string>
        <key>OLLAMA_KEEP_ALIVE</key>
        <string>7200h</string>
        <key>OLLAMA_NUM_PARALLEL</key>
        <string>4</string>
        <key>OLLAMA_FLASH_ATTENTION</key>
        <string>true</string>
        <key>OLLAMA_MULTIUSER_CACHE</key>
        <string>true</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/log/com.ollama.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/log/com.ollama.err.log</string>
</dict>
</plist>
EOF
    cleanup() {
        rm -f "$PLIST_TEMP"
    }
    trap cleanup EXIT

    mkdir -p /tmp/log

    touch "/tmp/log/com.ollama.out.log"
    touch "/tmp/log/com.ollama.err.log"

    cp "$PLIST_TEMP" "$PLIST_PATH"
    launchctl load "$PLIST_PATH"

elif [[ "$COMMAND" == "uninstall" ]]; then
    launchctl unload "$PLIST_PATH"
    rm -f "$PLIST_PATH"
    rm -f "/tmp/log/com.ollama.out.log"
    rm -f "/tmp/log/com.ollama.err.log"

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
