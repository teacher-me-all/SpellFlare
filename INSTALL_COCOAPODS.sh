#!/bin/bash

# Script to install Homebrew and CocoaPods
# Run this with: bash INSTALL_COCOAPODS.sh

set -e

echo "🔧 Installing Homebrew and CocoaPods..."
echo ""

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    echo "✅ Homebrew already installed"
else
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Update Homebrew
echo ""
echo "🔄 Updating Homebrew..."
brew update

# Install CocoaPods
echo ""
echo "📦 Installing CocoaPods..."
brew install cocoapods

# Verify installation
echo ""
echo "✅ Verifying installation..."
pod --version

echo ""
echo "✅ Setup complete!"
echo "CocoaPods version: $(pod --version)"
echo ""
echo "🎯 Next step: I will now migrate your project from Swift Package Manager to CocoaPods"
