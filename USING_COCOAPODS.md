# Using Your Project with CocoaPods

## ✅ Migration Complete

Your project now uses CocoaPods for Google AdMob dependencies.

---

## Opening the Project

### ⚠️ IMPORTANT: Always open the WORKSPACE, not the project

```bash
# ✅ CORRECT:
open spelling-bee.xcworkspace

# ❌ WRONG (will not work anymore):
# open spelling-bee.xcodeproj
```

Or in Xcode:
- **File → Open** → Select `spelling-bee.xcworkspace`

---

## Building & Running

Everything works the same as before, just open the `.xcworkspace` file.

### In Xcode:
1. Open `spelling-bee.xcworkspace`
2. Select your device/simulator
3. Click Run (⌘+R)

### Command Line:
```bash
# Build
xcodebuild -workspace spelling-bee.xcworkspace \
  -scheme "spelling-bee iOS App" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# Archive
xcodebuild -workspace spelling-bee.xcworkspace \
  -scheme "spelling-bee iOS App" \
  -archivePath build/SpellFlare.xcarchive \
  archive
```

---

## Archiving & Uploading to App Store

### Step 1: Archive
1. Open `spelling-bee.xcworkspace` in Xcode
2. Select **Any iOS Device** as destination
3. **Product → Archive**
4. Wait for archive to complete

### Step 2: Distribute
1. Xcode Organizer opens automatically
2. Click **Distribute App**
3. Choose **App Store Connect**
4. Follow the prompts

### Step 3: Handle dSYM Warning
When you see:
```
Upload Symbols Failed
The archive did not include a dSYM for GoogleMobileAds.framework
The archive did not include a dSYM for UserMessagingPlatform.framework
```

**→ Click "Continue"** ✅

Your app will upload successfully!

---

## Managing Dependencies

### Update Google AdMob SDK:
```bash
# Check for updates
pod outdated

# Update to latest version
pod update Google-Mobile-Ads-SDK

# Update all pods
pod update
```

### Add New Dependencies:
1. Edit `Podfile`
2. Add new pod: `pod 'SomePod', '~> 1.0'`
3. Run: `pod install`

### Remove CocoaPods (if needed later):
```bash
pod deintegrate
rm Podfile Podfile.lock
rm -rf Pods/
rm -rf spelling-bee.xcworkspace
```

---

## Project Structure

```
spelling-bee/
├── spelling-bee.xcworkspace  ← Open this
├── spelling-bee.xcodeproj    ← Don't open directly
├── Podfile                   ← Dependencies configuration
├── Podfile.lock              ← Locked versions (commit to git)
├── Pods/                     ← Installed dependencies (don't commit to git)
│   ├── Google-Mobile-Ads-SDK/
│   └── GoogleUserMessagingPlatform/
├── spelling-bee iOS App/     ← Your app code
└── ...
```

---

## Git Considerations

### Should Commit:
- ✅ `Podfile`
- ✅ `Podfile.lock`
- ✅ `.xcworkspace` (optional, but recommended)

### Should NOT Commit:
- ❌ `Pods/` folder (add to `.gitignore`)

### Example `.gitignore` additions:
```
# CocoaPods
Pods/
*.xcworkspace/xcuserdata/
```

### After cloning on a new machine:
```bash
cd spelling-bee
pod install
open spelling-bee.xcworkspace
```

---

## Code Changes

### No Import Changes Needed! ✅

Your code already uses:
```swift
import GoogleMobileAds
```

This works with both SPM and CocoaPods. No changes needed to your Swift files!

---

## FAQ

### Q: Why can't I open the `.xcodeproj` anymore?
**A:** CocoaPods creates a workspace that includes both your project and the Pods project. You must use the workspace for proper linking.

### Q: What if I see "library not found for -lPods-spelling-bee iOS App"?
**A:** You opened the `.xcodeproj` instead of `.xcworkspace`. Close Xcode and open the workspace.

### Q: Do I need to run `pod install` after pulling from git?
**A:** Yes, if the `Podfile.lock` changed or if `Pods/` folder is not committed.

### Q: Will the dSYM warnings go away?
**A:** No, Google doesn't provide dSYMs. Just click "Continue" during upload. This is normal.

---

## Summary

✅ **Always open:** `spelling-bee.xcworkspace`
✅ **Build/Run:** Works exactly the same as before
✅ **Archive/Upload:** Click "Continue" on dSYM warnings
✅ **Commit to git:** `Podfile`, `Podfile.lock`
❌ **Don't commit:** `Pods/` folder

Your project is ready to use!
