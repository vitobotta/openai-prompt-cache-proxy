#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <binary_path> <model_path> <label> <port>"
    exit 1
fi

BINARY_PATH=$1
MODEL_PATH=$2
LABEL=$3
PORT=$4

PLIST_PATH="/Library/LaunchDaemons/com.llama-server.${LABEL}.plist"

PLIST_CONTENT="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
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
</plist>"

echo "${PLIST_CONTENT}" | sudo tee "${PLIST_PATH}" > /dev/null

sudo chown root:wheel "${PLIST_PATH}"
sudo chmod 644 "${PLIST_PATH}"

sudo launchctl load "${PLIST_PATH}"

echo "Daemon created and loaded with label: com.llama-server.${LABEL}"

echo "Checking if the daemon is running..."
sudo launchctl list | grep "com.llama-server.${LABEL}"
