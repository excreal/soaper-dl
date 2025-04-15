#!/usr/bin/env bash

# 🚿 Soaper-DL Dependency Setup Script
set -eo pipefail

check_apt() {
    # 🧠 Check if apt package manager exists
    command -v apt >/dev/null 2>&1 && [ -f /etc/debian_version ]
}

install_deps() {
    echo "🔍 Detected Debian-based system. Installing dependencies..."
    
    # Update package lists with progress
    echo "📦 Updating package lists..."
    sudo apt update -qq
    
    # Install core packages
    echo "📥 Installing required packages:"
    echo "   curl      🌐 Data transfer"
    echo "   jq        📄 JSON processor"
    echo "   fzf       🔍 Fuzzy finder"
    echo "   ffmpeg    🎞️ Media toolkit"
    echo "   golang    🐹 Go language"
    echo "   aria2     🚀 Advanced downloader"
    
    sudo apt install -y --no-install-recommends \
        curl \
        jq \
        fzf \
        ffmpeg \
        golang \
        aria2

    # Install pup using Go
    echo "🔧 Installing pup (HTML parser)..."
    export GOPATH="${HOME}/go"
    export PATH="${PATH}:${GOPATH}/bin"
    if ! go install github.com/ericchiang/pup@latest; then
        echo "❌ Pup installation failed!"
        echo "   Ensure Go is properly configured and in your PATH"
        exit 1
    fi

    echo -e "\n✅ All dependencies successfully installed!"
    echo "   Note: You may need to add ${GOPATH}/bin to your PATH"
    echo "   Add this to your shell config:"
    echo "   export PATH=\"\$PATH:${GOPATH}/bin\""
}

manual_install() {
    echo -e "\n⚠️  This script currently only supports Debian-based systems"
    echo "🔧 Manual installation required:"
    
    echo -e "\n🧰 Core Packages:"
    echo "  curl      🌐  Data transfer      )"
    echo "  jq        📄  JSON processor     )"
    echo "  fzf       🔍  Fuzzy finder       )"
    echo "  ffmpeg    🎥  Media processing   )"
    echo "  aria2     🚀  Download manager   )"
    echo "  golang    🐹  Go language        )"
    
    echo -e "\n🐛 Pup Installation:"
    echo "  go install github.com/ericchiang/pup@latest"
    
    echo -e "\n💡 For other distributions:"
    echo "  Use equivalent package manager commands for your system"
    echo "  Ensure Go 1.16+ is installed for pup"
}

main() {
    echo -e "\n🚿 Soaper-DL Dependency Installer 🧼"
    echo "----------------------------------------"
    
    if check_apt; then
        install_deps
    else
        manual_install
        exit 1
    fi
}

main "$@"