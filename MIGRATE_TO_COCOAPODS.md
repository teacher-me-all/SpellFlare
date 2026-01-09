# Migration to CocoaPods - Step by Step

## ✅ Status

- [x] CocoaPods installed
- [x] Podfile created
- [ ] Remove Swift Package Manager dependencies (YOU DO THIS IN XCODE)
- [ ] Install pods
- [ ] Build and test

---

## Step 1: Remove Swift Package Manager Dependencies (IN XCODE)

**⚠️ IMPORTANT: Do this in Xcode, NOT via command line**

1. **Open the project in Xcode:**
   ```bash
   open spelling-bee.xcodeproj
   ```

2. **In Xcode, select the project** (blue icon at top of navigator)

3. **Click the "spelling-bee" project** (not the target)

4. **Select the "Package Dependencies" tab** (near the top)

5. **You should see:**
   - `swift-package-manager-google-mobile-ads`
   - Possibly `swift-package-manager-google-user-messaging-platform`

6. **Select each package** and click the **"-" (minus) button** to remove it

7. **Save** (⌘+S) and **close Xcode**

8. **Come back here and type "done"**

---

## Step 2: Install CocoaPods (AUTOMATIC)

Once you type "done", I will automatically:
- Run `pod install`
- Create `spelling-bee.xcworkspace`
- Configure the project for CocoaPods
- Update imports if needed
- Test the build

---

## What Will Change

### Before (SPM):
- Open: `spelling-bee.xcodeproj`
- Dependencies: Swift Package Manager
- No dSYM files for Google frameworks

### After (CocoaPods):
- Open: `spelling-bee.xcworkspace` ⭐
- Dependencies: CocoaPods (`Pods/` folder)
- **Full dSYM files included** ✅
- No more upload warnings!

---

## Ready?

1. Open Xcode: `open spelling-bee.xcodeproj`
2. Remove the Google packages (steps above)
3. Close Xcode
4. Type "done" here

I'll handle the rest automatically!
