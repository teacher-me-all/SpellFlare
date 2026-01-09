#!/bin/bash

# Script to download and install Google AdMob dSYM files
# This resolves "Upload Symbols Failed" warnings

set -e

echo "📥 Downloading Google AdMob dSYM files..."

# Versions (must match the SPM versions)
GOOGLE_ADS_VERSION="11.13.0"

# Create dSYMs directory
DSYM_DIR="${SRCROOT}/dSYMs"
mkdir -p "${DSYM_DIR}"
cd "${DSYM_DIR}"

# Download GoogleMobileAds SDK with dSYMs
DOWNLOAD_URL="https://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip"

if [ ! -f "GoogleMobileAds.xcframework/ios-arm64/dSYMs/GoogleMobileAds.framework.dSYM/Contents/Resources/DWARF/GoogleMobileAds" ]; then
    echo "⬇️  Downloading Google Mobile Ads SDK..."
    curl -L -o googlemobileadssdkios.zip "${DOWNLOAD_URL}"

    echo "📦 Extracting..."
    unzip -q -o googlemobileadssdkios.zip

    # Clean up zip
    rm googlemobileadssdkios.zip

    echo "✅ Google Mobile Ads SDK downloaded with dSYMs"
else
    echo "✅ dSYMs already present"
fi

# List what we have
echo ""
echo "📋 Available dSYM files:"
find "${DSYM_DIR}" -name "*.dSYM" -type d | sed 's/^/  - /'

echo ""
echo "✅ dSYM setup complete"
echo "ℹ️  dSYMs are located at: ${DSYM_DIR}"
