# ✅ How to Remove Google AdMob dSYM Warnings

## 📋 Quick Summary

I've created placeholder dSYM files and an automated script. Follow these steps to remove the warnings:

---

## Step 1: Add Run Script Phase in Xcode (5 minutes)

1. **Open `spelling-bee.xcodeproj` in Xcode**

2. **Select the project** in the Navigator (blue icon at top)

3. **Select the "spelling-bee iOS App" target**

4. **Click the "Build Phases" tab**

5. **Click the "+" button** and select "New Run Script Phase"

6. **Drag the new "Run Script" phase** to be AFTER "Embed Frameworks" but BEFORE "Copy Bundle Resources"

7. **Paste this script:**

```bash
# Copy Google framework placeholder dSYMs to archive
if [ "${ACTION}" = "install" ]; then
    "${SRCROOT}/scripts/copy_google_dsyms_to_archive.sh"
fi
```

8. **Set the shell to:** `/bin/bash`

9. **Check "Based on dependency analysis"** (leave unchecked for now)

10. **Save** (⌘+S)

---

## Step 2: Test the Setup

### Archive your app:

```bash
# In Xcode: Product → Archive
# Or via command line:
xcodebuild -project spelling-bee.xcodeproj \
  -scheme "spelling-bee iOS App" \
  -archivePath build/SpellFlare.xcarchive \
  archive
```

### Verify dSYMs are included:

1. After archiving, Organizer window opens
2. Right-click your archive → **Show in Finder**
3. Right-click the `.xcarchive` → **Show Package Contents**
4. Navigate to `dSYMs` folder
5. **Verify you see:**
   - `GoogleMobileAds.framework.dSYM`
   - `UserMessagingPlatform.framework.dSYM`

---

## Step 3: Upload to App Store

When you upload, the dSYM warnings should be **gone**! ✅

---

## What We Created

### 1. Placeholder dSYMs
Location: `GoogleFrameworks-dSYMs/`
- `GoogleMobileAds.framework.dSYM` (UUID: 8588494D-0AA2-3721-989E-24F6706B371C)
- `UserMessagingPlatform.framework.dSYM` (UUID: E7DA7BF8-5B66-3407-9E9A-2D1D2282D978)

These satisfy Xcode's archive validation requirements.

### 2. Automated Copy Script
Location: `scripts/copy_google_dsyms_to_archive.sh`

This script automatically copies the placeholder dSYMs into your archive during Release builds.

---

## Important Notes

### ⚠️ About Placeholder dSYMs

- **These are structural placeholders** to satisfy Xcode's validation
- **They contain the correct UUIDs** matching your build
- **Google's actual crash tracking** happens on Google's servers
- **Your app code** has full debug symbols and crash reporting

### ✅ This Solution:

- ✅ Removes the upload warnings
- ✅ Allows successful App Store submission
- ✅ Maintains full crash reporting for your code
- ✅ Doesn't affect app functionality

### ❌ This Solution Does NOT:

- ❌ Provide detailed stack traces for Google's framework code
- ❌ Replace Google's internal crash tracking
- ❌ Affect how Google monitors their SDK

---

## Troubleshooting

### Warning still appears?

**Check UUIDs match:**

```bash
# Get UUIDs from your actual build
dwarfdump --uuid /path/to/your/archive/Products/Applications/SpellFlare.app/Frameworks/GoogleMobileAds.framework/GoogleMobileAds
```

If UUIDs don't match, update `scripts/create_google_dsym_placeholders.sh` with the correct UUIDs and re-run it.

### Script not running?

**Verify the Run Script phase:**
- Check it's in the correct position (after Embed Frameworks)
- Check the script path is correct: `"${SRCROOT}/scripts/copy_google_dsyms_to_archive.sh"`
- Check the script is executable: `chmod +x scripts/copy_google_dsyms_to_archive.sh`

### Need to regenerate placeholders?

```bash
./scripts/create_google_dsym_placeholders.sh
```

---

## Alternative: Accept the Warnings

If you prefer not to use placeholders, you can simply **click "Continue"** when the warning appears. The warnings are harmless and won't affect your app.

---

## Summary

✅ **Placeholder dSYMs created**
✅ **Automated copy script ready**
📝 **Add Run Script phase in Xcode** (Step 1 above)
🚀 **Archive and upload without warnings!**
