#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <binary_path> <model_path> <label> <port>"
    exit 1
fi

BINARY_PATH=$1
MODEL_PATH=$2
LABEL=$3
PORT=$4

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary file not found at $BINARY_PATH"
    exit 1
fi

if [ ! -f "$MODEL_PATH" ]; then
    echo "Error: Model file not found at $MODEL_PATH"
    exit 1
fi

PLIST_PATH="/Library/LaunchDaemons/com.llama-server.${LABEL}.plist"

PLIST_TEMP=$(mktemp)

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
        <string>8192</string>
        <string>--n-predict</string>
        <string>4096</string>
        <string>--parallel</string>
        <string>4</string>
        <string>--cont-batching</string>
        <string>--flash-attn</string>
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
    <string>/var/log/com.llama-server.${LABEL}.out.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/com.llama-server.${LABEL}.err.log</string>
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

echo "Daemon created and loaded with label: com.llama-server.${LABEL}"

echo "Checking if the daemon is running..."
sudo launchctl list | grep "com.llama-server.${LABEL}"
