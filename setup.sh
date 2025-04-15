#!/usr/bin/env bash
set -e

# Define required Go version
GO_VERSION="1.24.2"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"

# Update PATH for current session and future shell sessions
echo "Setting up PATH..."
echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"' >> ~/.bashrc
source ~/.bashrc
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

# Clone repository to home directory
echo "Cloning soaper-dl repository..."
if [ -d "$HOME/soaper-dl" ]; then
    echo "Repository already exists at ~/soaper-dl. Updating..."
    git -C "$HOME/soaper-dl" pull
else
    git clone https://github.com/excreal/soaper-dl.git "$HOME/soaper-dl"
fi

# Check existing Go version
if command -v go &>/dev/null; then
    INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if [[ "$INSTALLED_GO_VERSION" == "$GO_VERSION" ]]; then
        echo "Go $GO_VERSION is already installed. Skipping reinstallation."
    else
        echo "Removing existing Go installation (Version: $INSTALLED_GO_VERSION)..."
        sudo rm -rf /usr/local/go
    fi
else
    echo "Go is not installed. Proceeding with installation..."
fi

# Install Go if not installed
if ! command -v go &>/dev/null; then
    echo "Installing Go $GO_VERSION..."
    wget "https://go.dev/dl/${GO_TAR}"
    sudo tar -C /usr/local -xzf "$GO_TAR"
    rm "$GO_TAR"
    source ~/.bashrc
fi

# Ensure Go is in PATH for the rest of the script
export PATH="$PATH:/usr/local/go/bin"

# Add Go alias as fallback
echo "alias go='/usr/local/go/bin/go'" >> ~/.bashrc
source ~/.bashrc

# Verify Go installation
if ! command -v go &>/dev/null; then
    echo "Error: Go command not found after installation."
    exit 1
fi

# Install required packages
if command -v apt &>/dev/null; then
    echo "Using apt for installation..."
    sudo apt update
    sudo apt install -y curl jq fzf ffmpeg aria2 git
else
    echo "No supported package manager found (apt)."
    echo "Please install curl, jq, fzf, ffmpeg, aria2, and git manually."
    exit 1
fi

# Install pup using Go
echo "Installing pup using Go..."
go install github.com/ericchiang/pup@latest

# Ensure Go bin directory is in PATH
GOBIN="${GOPATH:-$HOME/go}/bin"
if ! echo "$PATH" | grep -q "$GOBIN"; then
    echo "Adding $GOBIN to PATH..."
    export PATH="$PATH:$GOBIN"
    echo 'export PATH="$PATH:'"$GOBIN"'"' >> ~/.bashrc
    source ~/.bashrc
fi

# Remove existing yt-dlp installations
echo "Checking for existing yt-dlp installations..."
if command -v yt-dlp &>/dev/null; then
    echo "Found existing yt-dlp installation. Removing..."
    sudo rm -f "$(command -v yt-dlp)"
fi

# Install yt-dlp
echo "Downloading yt-dlp from the latest release..."
YT_DLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"
curl -L -o yt-dlp "$YT_DLP_URL"

# Make executable and move to /usr/bin
echo "Installing yt-dlp to /usr/bin..."
chmod +x yt-dlp
sudo mv yt-dlp /usr/bin/yt-dlp

echo "Installation complete!"
echo "Repository location: ~/soaper-dl"
echo "You can now run: cd ~/soaper-dl &&  bash soaper-dl -n 'Game of Thrones' -e '1.1-1.8' "