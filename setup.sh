#!/usr/bin/env bash
set -e

# Set consistent GOPATH configuration
CUSTOM_GOPATH="$HOME/gopath"
mkdir -p "$CUSTOM_GOPATH"

# Update environment variables

export GOPATH="$CUSTOM_GOPATH"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
echo "export GOPATH=\"$CUSTOM_GOPATH\"" >> ~/.bashrc

# Clone repository
REPO_DIR="$HOME/soaper-dl"
echo "Cloning/updating repository..."
if [ -d "$REPO_DIR" ]; then
    git -C "$REPO_DIR" pull
else
    git clone https://github.com/excreal/soaper-dl.git "$REPO_DIR"
fi

# Install Go if missing
GO_VERSION="1.24.2"
if ! command -v go &>/dev/null; then
    echo "Installing Go $GO_VERSION..."
    GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
    wget "https://go.dev/dl/${GO_TAR}"
    sudo tar -C /usr/local -xzf "$GO_TAR"
    rm "$GO_TAR"
fi

# Install pup to custom GOPATH
if ! command -v pup &>/dev/null; then
    echo "Installing pup to $GOPATH..."
    GOBIN="$GOPATH/bin" go install github.com/ericchiang/pup@latest
fi

# Install yt-dlp only if missing
if ! command -v yt-dlp &>/dev/null; then
    echo "Installing yt-dlp..."
    YT_DLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"
    curl -L -o yt-dlp "$YT_DLP_URL"
    chmod +x yt-dlp
    sudo mv yt-dlp /usr/bin/yt-dlp
fi

# Make script executable
chmod +x "$REPO_DIR/soaper-dl.sh"

sudo apt update
sudo apt install fzf curl jq ffmpeg zip

# Verify installations
echo "Verifying environment:"
echo -e "\nGo version:"
go version
echo -e "\nGOPATH:"
go env GOPATH
echo -e "\nInstalled components:"
ls -lh "$GOPATH/bin/pup" /usr/bin/yt-dlp

echo -e "\nInstallation complete!"
echo "Run with: $REPO_DIR/soaper-dl.sh -n 'Game of Thrones' -e '1.1-1.8'"