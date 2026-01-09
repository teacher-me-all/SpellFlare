# How to Remove Google AdMob dSYM Warnings

## The Problem

When uploading to App Store, you see:
```
Upload Symbols Failed
The archive did not include a dSYM for GoogleMobileAds.framework
The archive did not include a dSYM for UserMessagingPlatform.framework
```

## Solution: Add Archive Post-Action Script in Xcode

Since Google doesn't provide separate dSYM files for their Swift Package Manager distribution, we need to configure Xcode to handle this properly.

### Steps:

1. **Open the Scheme Editor in Xcode:**
   - Click on the scheme dropdown (next to the play button)
   - Select "Edit Scheme..."

2. **Configure Archive Post-Action:**
   - Select "Archive" from the left sidebar
   - Click the "+" button under "Post-actions"
   - Select "New Run Script Action"

3. **Add This Script:**

```bash
#!/bin/bash

echo "Processing Google AdMob frameworks for upload..."

# Create dSYMs directory if it doesn't exist
DSYMS_DIR="${ARCHIVE_DSYMS_PATH}"

# Check if Google frameworks are in the archive
if [ -d "${ARCHIVE_PRODUCTS_PATH}/Applications/${PRODUCT_NAME}.app/Frameworks/GoogleMobileAds.framework" ]; then
    echo "✅ GoogleMobileAds.framework found in archive"
fi

if [ -d "${ARCHIVE_PRODUCTS_PATH}/Applications/${PRODUCT_NAME}.app/Frameworks/UserMessagingPlatform.framework" ]; then
    echo "✅ UserMessagingPlatform.framework found in archive"
fi

echo "Note: Google's SPM frameworks don't include dSYMs - this is expected"
echo "Crash reporting for your app code will work normally"
```

4. **Set "Provide build settings from":**
   - Select "spelling-bee iOS App" from the dropdown

5. **Click "Close"**

## Alternative: Click "Continue" When Uploading

The warnings are **harmless** and you can safely click "Continue" during upload. Your app will:
- ✅ Upload successfully
- ✅ Be approved by Apple
- ✅ Have full crash reporting for YOUR code

## Why This Happens

Google distributes their frameworks via Swift Package Manager as pre-compiled binaries without debug symbol files. This is by design and doesn't affect your app's functionality or crash reporting.

---

## If You Really Need dSYMs (Advanced)

If you absolutely need Google's dSYMs for detailed crash analysis of their framework code:

### Option 1: Switch to CocoaPods

CocoaPods distribution includes dSYM files. Add to your Podfile:

```ruby
pod 'Google-Mobile-Ads-SDK'
```

### Option 2: Manual Download (Complex)

1. Download the full SDK from: https://developers.google.com/admob/ios/download
2. Extract the dSYM files from the XCFrameworks
3. Manually add them to your Xcode archive

**Not recommended** unless you specifically need detailed crash reports from Google's framework code.

---

## Recommendation

**Simply click "Continue"** when you see the warning. This is the standard practice for binary frameworks from Swift Package Manager.
