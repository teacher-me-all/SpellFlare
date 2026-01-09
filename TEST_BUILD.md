# Test Your CocoaPods Build

## ✅ Fixes Applied

1. Disabled User Script Sandboxing in build settings
2. Fixed resource copy script to use `TEMP_DIR` instead of `Pods/`
3. Removed incompatible `realpath -m` command

## 🧪 Test the Build

### Option 1: Xcode GUI (Recommended)

1. **Open the workspace:**
   ```bash
   open spelling-bee.xcworkspace
   ```

2. **Select a simulator** (e.g., iPhone 17)

3. **Click Run** (⌘+R) or **Product → Build** (⌘+B)

4. **Expected result:** Build succeeds and app runs

---

### Option 2: Command Line

```bash
# Clean build
xcodebuild -workspace spelling-bee.xcworkspace \
  -scheme "spelling-bee iOS App" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  clean build
```

**Expected output:** `** BUILD SUCCEEDED **`

---

## 🎯 What to Look For

### ✅ Success Indicators:
- Build completes without errors
- App launches in simulator
- No "Operation not permitted" errors
- No "realpath: illegal option" errors

### ⚠️ Warnings You Can Ignore:
- AppIntents metadata warnings (not relevant)
- CocoaPods warnings about file lists

---

## 📦 Archive Test (Optional)

To test archiving for App Store:

1. **Open workspace:** `open spelling-bee.xcworkspace`
2. **Select "Any iOS Device"** as destination
3. **Product → Archive**
4. **Wait for completion**

**Expected result:** Archive succeeds, appears in Organizer

When you distribute:
- You'll see dSYM warnings for Google frameworks
- **Click "Continue"** → Upload succeeds ✅

---

## 🐛 If Build Still Fails

If you see any errors, please share:
1. The full error message
2. Whether it's in Xcode or command line
3. Any specific file paths mentioned

The fixes should resolve the sandbox and realpath issues!
