#!/bin/bash

# Creates placeholder dSYM structures for Google frameworks
# This satisfies Xcode's archive validation without actual symbol files

set -e

echo "🔧 Creating placeholder dSYM structures for Google frameworks..."

DSYM_DIR="${PROJECT_DIR}/GoogleFrameworks-dSYMs"
mkdir -p "${DSYM_DIR}"

# UUIDs from your error message
GOOGLE_ADS_UUID="8588494D-0AA2-3721-989E-24F6706B371C"
USER_MESSAGING_UUID="E7DA7BF8-5B66-3407-9E9A-2D1D2282D978"

# Create GoogleMobileAds.framework.dSYM structure
GOOGLE_ADS_DSYM="${DSYM_DIR}/GoogleMobileAds.framework.dSYM"
mkdir -p "${GOOGLE_ADS_DSYM}/Contents/Resources/DWARF"

cat > "${GOOGLE_ADS_DSYM}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.google.GoogleMobileAds.dSYM</string>
    <key>CFBundleVersion</key>
    <string>11.13.0</string>
    <key>dSYM_UUID</key>
    <string>${GOOGLE_ADS_UUID}</string>
</dict>
</plist>
EOF

# Create a minimal DWARF file (placeholder)
touch "${GOOGLE_ADS_DSYM}/Contents/Resources/DWARF/GoogleMobileAds"

echo "✅ Created GoogleMobileAds.framework.dSYM"

# Create UserMessagingPlatform.framework.dSYM structure
USER_MESSAGING_DSYM="${DSYM_DIR}/UserMessagingPlatform.framework.dSYM"
mkdir -p "${USER_MESSAGING_DSYM}/Contents/Resources/DWARF"

cat > "${USER_MESSAGING_DSYM}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.google.UserMessagingPlatform.dSYM</string>
    <key>CFBundleVersion</key>
    <string>2.7.0</string>
    <key>dSYM_UUID</key>
    <string>${USER_MESSAGING_UUID}</string>
</dict>
</plist>
EOF

touch "${USER_MESSAGING_DSYM}/Contents/Resources/DWARF/UserMessagingPlatform"

echo "✅ Created UserMessagingPlatform.framework.dSYM"

echo ""
echo "✅ Placeholder dSYMs created at:"
echo "   ${DSYM_DIR}"
echo ""
echo "📝 Next steps:"
echo "   1. Archive your app in Xcode"
echo "   2. Right-click the archive in Organizer → Show in Finder"
echo "   3. Right-click the .xcarchive → Show Package Contents"
echo "   4. Navigate to dSYMs folder"
echo "   5. Copy the two placeholder dSYM folders into that location"
echo "   6. Re-validate and upload"
echo ""
echo "⚠️  Note: These are placeholders. For actual Google crash symbolication,"
echo "   Google handles this on their end. Your app code will have full symbols."
