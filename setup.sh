#!/usr/bin/env bash
set -eo pipefail

# Configuration
GO_VERSION="1.24.1"
PUP_VERSION="v0.24.0"
YT_DLP_URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux"

# Setup environment
setup_paths() {
    echo "🔧 Configuring system paths..."
    export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
    grep -q "/usr/local/go/bin" ~/.bashrc || \
        echo 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
}

# Go installation
install_go() {
    if command -v go &>/dev/null; then
        local installed_ver=$(go version | awk '{print $3}' | tr -d 'go')
        if [[ "$(printf "%s\n%s" "$installed_ver" "$GO_VERSION" | sort -V | head -n1)" == "$GO_VERSION" ]]; then
            echo "✓ Go $installed_ver meets requirements"
            return
        fi
        echo "🔄 Upgrading Go from $installed_ver to $GO_VERSION..."
        sudo rm -rf /usr/local/go
    fi

    echo "📥 Installing Go $GO_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fsSL "https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz" -o "$tmp_dir/go.tar.gz"
    sudo tar -C /usr/local -xzf "$tmp_dir/go.tar.gz"
    rm -rf "$tmp_dir"
}

# Dependency checks
check_dependencies() {
    local deps=("curl" "jq" "fzf" "ffmpeg" "aria2")
    local missing=()
    
    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "📦 Installing missing dependencies: ${missing[*]}..."
        sudo apt update
        sudo apt install -y "${missing[@]}"
    fi
}

# Pup installation
install_pup() {
    echo "🐶 Installing pup $PUP_VERSION..."
    go install "github.com/ericchiang/pup@$PUP_VERSION" || {
        echo "❌ Pup installation failed! Common fixes:"
        echo "1. Ensure Go $GO_VERSION is properly installed"
        echo "2. Verify network connection"
        echo "3. Check GOPATH configuration"
        exit 1
    }
}

# yt-dlp installation
install_ytdlp() {
    echo "🎥 Installing yt-dlp..."
    sudo curl -L "$YT_DLP_URL" -o /usr/bin/yt-dlp
    sudo chmod +x /usr/bin/yt-dlp
}

main() {
    # Check system compatibility
    [[ -f /etc/debian_version ]] || {
        echo "❌ This script currently only supports Debian-based systems"
        exit 1
    }

    # Elevate privileges
    sudo -v

    # Execution flow
    setup_paths
    install_go
    check_dependencies
    install_pup
    install_ytdlp

    echo -e "\n✅ All components successfully installed!"
    echo -e "➜ Restart your shell or run: source ~/.bashrc\n"
}

main "$@"