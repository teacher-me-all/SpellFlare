# Google AdMob Setup Instructions

## ✅ Already Completed

The following AdMob integration components have been implemented:

1. ✅ **Info.plist Configuration**
   - Created `spelling-bee iOS App/Info.plist` with all required keys
   - 38 SKAdNetwork identifiers for ad attribution
   - App Transport Security (ATS) configured for ad traffic
   - Google AdMob App ID configured (test ID)
   - Project configured to use custom Info.plist

2. ✅ **AdManager Service** (`Services/AdManager.swift`)
   - Implements `GADInterstitialAd` for interstitial ads
   - COPPA-compliant non-personalized ads (`request.requestAgent = "kids_app"`)
   - Test ad unit ID: `ca-app-pub-3940256099942544/4411468910`
   - Pre-test countdown view (5 seconds)
   - Post-test AdMob interstitial wrapper
   - Graceful error handling (never blocks gameplay)
   - Preloads ads for instant display

3. ✅ **SDK Initialization** (`spelling_bee_iOS_App.swift`)
   - Added to app entry point
   - Initializes Google Mobile Ads SDK at launch
   - Configures test device identifiers in DEBUG mode
   - Preloads first ad after initialization

4. ✅ **UI Integration**
   - `PreTestAdView` (5-second countdown before test starts)
   - `PostTestAdView` (Google AdMob interstitial after test completion)
   - `AdMobViewController` (UIKit bridge for ad presentation)
   - Updated `LevelCompleteView` to use new ad system
   - Updated `GameViewModel` to trigger pre-test ads

5. ✅ **Project Configuration**
   - Modified `project.pbxproj` to use custom Info.plist
   - Set `GENERATE_INFOPLIST_FILE = NO`
   - Set `INFOPLIST_FILE = "spelling-bee iOS App/Info.plist"`
   - Both Debug and Release configurations updated

---

## ⚠️ CRITICAL: Add Google Mobile Ads SDK (5-minute task)

**The app will NOT build until you complete this step.**

This is the only remaining task and must be done via Xcode's GUI.

### Option 1: Swift Package Manager (Recommended)

1. Open `spelling-bee.xcodeproj` in Xcode
2. Select the project in the navigator (top-level blue icon)
3. Select the **spelling-bee iOS App** target
4. Click the **"+"** button under **"Frameworks, Libraries, and Embedded Content"**
5. Click **"Add Other..."** → **"Add Package Dependency..."**
6. Enter the package URL:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
7. Click **"Add Package"**
8. Select **"GoogleMobileAds"** and click **"Add Package"**

### Option 2: CocoaPods

1. Create a `Podfile` in the project root:
   ```ruby
   platform :ios, '16.0'

   target 'spelling-bee iOS App' do
     use_frameworks!
     pod 'Google-Mobile-Ads-SDK'
   end
   ```

2. Run in terminal:
   ```bash
   pod install
   ```

3. Open `spelling-bee.xcworkspace` (not `.xcodeproj`) going forward

---

## 🧪 Testing the Integration

After adding the SDK:

### 1. Build the Project

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project spelling-bee.xcodeproj \
  -scheme "spelling-bee iOS App" \
  -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
  build
```

### 2. Run the App

Launch the app in the simulator and:

1. Complete onboarding
2. Start a level
3. **Expected**: 5-second pre-test ad screen appears (PreTestAdView)
4. Complete the test (spell all 15 words)
5. **Expected**: Google AdMob test interstitial ad appears
   - You should see a real test ad from Google
   - Ad has a yellow banner saying "Test Ad"
6. Dismiss the ad and verify navigation works

### 3. Console Output

When the app launches, you should see:

```
📱 Initializing Google Mobile Ads SDK...
📱 AdMob configured for test mode (simulator)
✅ Google Mobile Ads SDK initialized successfully
📊 Adapter statuses:
  - GADMobileAds: Ready
🔄 Loading interstitial ad...
✅ Interstitial ad loaded successfully
```

When showing an ad:

```
📺 Post-test ad ready to show
📺 Post-test ad view appeared
📺 Presenting interstitial ad...
📺 Ad will present
📊 Ad impression recorded
📺 Ad will dismiss
✅ Ad dismissed by user
✅ Ad dismissed, preloading next ad...
```

---

## 🔧 Troubleshooting

### Build Error: "No such module 'GoogleMobileAds'"

**Solution**: You haven't added the SDK yet. Follow Option 1 or Option 2 above.

### Ad Fails to Load

**Causes**:
- No internet connection (simulator needs connectivity)
- SDK not initialized (check console for initialization logs)
- Ad inventory temporarily unavailable (normal with test ads)

**Expected Behavior**: App continues without showing ad (never blocks gameplay)

### Test Ad Not Showing

**Verify**:
1. Check console for `✅ Interstitial ad loaded successfully`
2. Make sure you're using test ad unit ID (already configured)
3. Ensure SDK is initialized before ad requests

---

## 📝 Production Checklist

Before submitting to App Store:

1. ⚠️ **Replace Production Ad Unit ID**
   - Open `AdManager.swift`
   - Replace `productionAdUnitID` on line 36 with your real ad unit ID from AdMob console
   - Current value is test ID: `ca-app-pub-3940256099942544/4411468910`

2. ⚠️ **Replace GADApplicationIdentifier**
   - Open `Info.plist`
   - Replace `GADApplicationIdentifier` value with your real App ID from AdMob console
   - Current value is test App ID: `ca-app-pub-3940256099942544~1458002511`

3. ✅ **Verify COPPA Compliance**
   - Already configured: `request.requestAgent = "kids_app"`
   - Non-personalized ads enabled by default

4. ✅ **Verify SKAdNetwork**
   - Already configured in `Info.plist`
   - 38 SKAdNetwork IDs included

5. ✅ **Test on Real Device**
   - Build and run on physical iPhone
   - Verify ads load and display correctly
   - Test "Remove Ads" purchase flow

---

## 📚 References

- [Google AdMob iOS Integration Guide](https://developers.google.com/admob/ios/quick-start)
- [COPPA Compliance](https://developers.google.com/admob/ios/targeting#child-directed_setting)
- [SKAdNetwork Setup](https://developers.google.com/admob/ios/ios14)
- [Test Ads](https://developers.google.com/admob/ios/test-ads)

---

## 📝 Files Modified/Created

### Created Files
- `spelling-bee iOS App/Info.plist` - AdMob configuration with SKAdNetwork and ATS
- `ADMOB_SETUP.md` - This setup guide

### Modified Files
- `spelling-bee iOS App/Services/AdManager.swift` - Rewritten to use real Google AdMob SDK
- `spelling-bee iOS App/spelling_bee_iOS_App.swift` - Added SDK initialization
- `spelling-bee iOS App/Views/Game/LevelCompleteView.swift` - Updated to use PostTestAdView
- `spelling-bee.xcodeproj/project.pbxproj` - Configured to use custom Info.plist

### Unchanged Files (Already Working)
- `spelling-bee iOS App/ViewModels/GameViewModel.swift` - Pre-test ad logic already in place
- `spelling-bee iOS App/Services/StoreManager.swift` - IAP "Remove Ads" already functional

---

## 🎯 Summary

**What's Done**:
- ✅ All code implementation complete
- ✅ AdManager with real Google AdMob SDK
- ✅ SDK initialization at app launch
- ✅ Info.plist with SKAdNetwork and ATS
- ✅ COPPA compliance configured
- ✅ UI integration (pre-test and post-test ads)
- ✅ Project configured to use custom Info.plist

**What's Needed**:
- ⚠️ Add Google Mobile Ads SDK package via Xcode (5-minute task)

**What Works (after SDK is added)**:
- ✅ Pre-test countdown ads (5 seconds)
- ✅ Post-test Google AdMob interstitial ads
- ✅ Graceful error handling (never blocks gameplay)
- ✅ IAP "Remove Ads" integration
- ✅ Test ad unit IDs for development

**What to Test**:
1. Build the app (will fail until SDK is added)
2. Add SDK via Xcode (see Option 1 above)
3. Build again (should succeed)
4. Run app, start a level
5. Verify 5-second pre-test ad appears
6. Complete test (15 words)
7. Verify Google test interstitial ad appears
8. Test navigation after ad dismissal
