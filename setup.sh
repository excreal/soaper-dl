#!/usr/bin/env bash

# 🚿 Soaper-DL Dependency Setup Script
set -eo pipefail

check_apt() {
    # 🧠 Check if apt package manager exists
    command -v apt-get >/dev/null 2>&1 && [ -f /etc/debian_version ]
}

install_deps() {
    echo "🔍 Detected Debian-based system. Installing dependencies..."

    echo "📦 Updating package lists..."
    sudo apt-get update -qq

    echo "📥 Installing required packages..."
    sudo apt-get install -y \
        curl \        # 🌐 Data transfer
        jq \          # 📄 JSON processor
        fzf \         # 🔎 Fuzzy finder
        ffmpeg \      # 🎞️ Media toolkit
        golang \      # 🐹 Go language
        aria2         # 🚀 Advanced downloader

    echo "🔧 Installing pup (HTML parser)..."
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
    go install github.com/ericchiang/pup@latest >/dev/null 2>&1 || {
        echo "❌ Failed to install pup. Please ensure Go is properly configured."
        exit 1
    }

    echo "✅ All dependencies installed successfully!"
}

manual_install() {
    echo "⚠️  This script currently only supports Debian-based systems"
    echo "🔧 Please install these dependencies manually:"
    echo
    echo "🧰 Required packages:"
    echo " - curl     🌐 Data transfer utility"
    echo " - jq       📄 JSON processor"
    echo " - fzf      🔍 Fuzzy finder"
    echo " - ffmpeg   🎥 Media processing"
    echo " - aria2    🚀 Downloader"
    echo " - golang   🐹 Programming language"
    echo " - pup      🐛 HTML processor"
    echo
    echo "💡 For non-Debian systems:"
    echo "  1️⃣  Use your system's package manager to install the equivalents"
    echo "  2️⃣  Install Go and run: go install github.com/ericchiang/pup@latest"
    echo "  3️⃣  Ensure all binaries are in your \$PATH"
}

main() {
    echo "🚿 Soaper-DL Dependency Installer 🧼"

    if check_apt; then
        install_deps
    else
        manual_install
        exit 1
    fi
}

main "$@"
