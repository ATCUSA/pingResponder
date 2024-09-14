#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 [-p port]"
  exit 1
}

# Default port is 5555
DEFAULT_PORT=5555
PORT=$DEFAULT_PORT

# Parse command-line arguments
while getopts "p:" opt; do
  case ${opt} in
    p )
      PORT=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check for required dependencies
declare -a dependencies=("curl" "unzip" "systemctl")

missing_dependencies=()

for cmd in "${dependencies[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    missing_dependencies+=("$cmd")
  fi
done

# Prompt to install missing dependencies
if [ ${#missing_dependencies[@]} -ne 0 ]; then
  echo "The following dependencies are missing: ${missing_dependencies[@]}"
  read -p "Do you want to install them? [y/N]: " install_deps
  if [[ "$install_deps" =~ ^[Yy]$ ]]; then
    sudo apt-get update
    for dep in "${missing_dependencies[@]}"; do
      sudo apt-get install -y $dep
    done
  else
    echo "Cannot proceed without installing dependencies."
    exit 1
  fi
fi

# Determine architecture
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
  TARGET="x86_64-unknown-linux-gnu"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
  TARGET="aarch64-unknown-linux-gnu"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# GitHub repository details
GITHUB_USER="ATCUSA"   # Replace with your GitHub username
REPO_NAME="pingResponder"      # Replace with your repository name

# Get latest release tag from GitHub
LATEST_TAG=$(curl --silent "https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
  echo "Could not determine the latest release."
  exit 1
fi

# Download the binary
ASSET_URL="https://github.com/${GITHUB_USER}/${REPO_NAME}/releases/download/${LATEST_TAG}/ping_server-${TARGET}.zip"

echo "Downloading ping_server for $TARGET from $ASSET_URL"

curl -L -o ping_server.zip "$ASSET_URL"

if [ $? -ne 0 ]; then
  echo "Failed to download the binary."
  exit 1
fi

# Unzip the binary
unzip ping_server.zip

if [ $? -ne 0 ]; then
  echo "Failed to unzip the binary."
  exit 1
fi

# Move binary to /usr/local/bin
sudo mv ping_server /usr/local/bin/

if [ $? -ne 0 ]; then
  echo "Failed to move the binary to /usr/local/bin."
  exit 1
fi

sudo chmod +x /usr/local/bin/ping_server

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/ping_server.service"

if [ -z "$PORT" ]; then
  PORT_OPTION=""
else
  PORT_OPTION="--port $PORT"
fi

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Ping Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ping_server $PORT_OPTION
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable ping_server
sudo systemctl start ping_server

echo "ping_server service installed and started on port $PORT."

# Check if ufw is active
if command -v ufw &> /dev/null; then
  if sudo ufw status | grep -q "Status: active"; then
    read -p "ufw (Uncomplicated Firewall) is active. Do you want to add a rule to allow traffic on port $PORT? [y/N]: " ufw_rule
    if [[ "$ufw_rule" =~ ^[Yy]$ ]]; then
      sudo ufw allow $PORT
      echo "ufw rule added to allow traffic on port $PORT."
    else
      echo "ufw rule not added. You may need to allow port $PORT manually."
    fi
  fi
fi
