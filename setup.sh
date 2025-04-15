#!/usr/bin/env bash
set -e

# Define required Go version
GO_VERSION="1.24.2"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"

# Update PATH for current session
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
echo 'export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"' >> ~/.bashrc

# Clone repository
echo "Cloning soaper-dl repository..."
if [ -d "$HOME/soaper-dl" ]; then
    echo "Updating existing repository..."
    git -C "$HOME/soaper-dl" pull
else
    git clone https://github.com/excreal/soaper-dl.git "$HOME/soaper-dl"
fi

# Make script executable
chmod +x "$HOME/soaper-dl/soaper-dl.sh"

# Check Go installation
if ! command -v go &>/dev/null; then
    echo "Installing Go $GO_VERSION..."
    wget "https://go.dev/dl/${GO_TAR}"
    sudo tar -C /usr/local -xzf "$GO_TAR"
    rm "$GO_TAR"
    export PATH="$PATH:/usr/local/go/bin"
fi

# Install pup if missing
if ! command -v pup &>/dev/null; then
    echo "Installing pup..."
    go install github.com/ericchiang/pup@latest
fi

# Install yt-dlp only if missing
if ! command -v yt-dlp &>/dev/null; then
    echo "Installing yt-dlp..."
    YT_DLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"
    curl -L -o yt-dlp "$YT_DLP_URL"
    chmod +x yt-dlp
    sudo mv yt-dlp /usr/bin/yt-dlp
else
    echo "yt-dlp already installed, skipping installation"
fi

echo "Installation complete!"
echo "Run with: ~/soaper-dl/soaper-dl.sh -n 'Game of Thrones' -e '1.1-1.8'"