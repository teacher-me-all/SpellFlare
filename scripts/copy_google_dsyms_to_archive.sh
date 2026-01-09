#!/bin/bash

# Automatically copy placeholder dSYMs to archive
# Add this as a "Run Script" build phase that runs during Archive

# Only run during archiving
if [ "${CONFIGURATION}" != "Release" ]; then
    echo "⏭️  Skipping dSYM copy (not a Release build)"
    exit 0
fi

if [ "${ACTION}" != "install" ]; then
    echo "⏭️  Skipping dSYM copy (not archiving)"
    exit 0
fi

echo "📦 Adding Google framework dSYMs to archive..."

SOURCE_DSYMS="${SRCROOT}/GoogleFrameworks-dSYMs"

# Check if placeholder dSYMs exist
if [ ! -d "${SOURCE_DSYMS}" ]; then
    echo "⚠️  Placeholder dSYMs not found at ${SOURCE_DSYMS}"
    echo "   Run: ./scripts/create_google_dsym_placeholders.sh"
    exit 0
fi

# Copy to build products
if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
    echo "📂 Copying dSYMs to: ${BUILT_PRODUCTS_DIR}"
    cp -R "${SOURCE_DSYMS}/GoogleMobileAds.framework.dSYM" "${BUILT_PRODUCTS_DIR}/" 2>/dev/null || true
    cp -R "${SOURCE_DSYMS}/UserMessagingPlatform.framework.dSYM" "${BUILT_PRODUCTS_DIR}/" 2>/dev/null || true
fi

# Also copy to DWARF_DSYM_FOLDER_PATH if it exists
if [ -n "${DWARF_DSYM_FOLDER_PATH}" ] && [ -d "${DWARF_DSYM_FOLDER_PATH}" ]; then
    echo "📂 Copying dSYMs to: ${DWARF_DSYM_FOLDER_PATH}"
    cp -R "${SOURCE_DSYMS}/GoogleMobileAds.framework.dSYM" "${DWARF_DSYM_FOLDER_PATH}/" 2>/dev/null || true
    cp -R "${SOURCE_DSYMS}/UserMessagingPlatform.framework.dSYM" "${DWARF_DSYM_FOLDER_PATH}/" 2>/dev/null || true
    echo "✅ dSYMs copied successfully"
else
    echo "⚠️  DWARF_DSYM_FOLDER_PATH not set"
fi

echo "✅ Google framework dSYMs added to archive"
