# Kids App Ad Safety Configuration

This document explains how SpellFlare ensures only age-appropriate, child-safe ads are shown.

## 🔒 Child Safety Protections Implemented

### 1. **Code-Level Protections (Already Implemented)**

#### SDK Configuration (AdManager.swift)
```swift
// Set at SDK initialization (BEFORE any ads load)
requestConfiguration.tag(forChildDirectedTreatment: true)
requestConfiguration.maxAdContentRating = .general
```

#### Per-Request Configuration
```swift
// Applied to EVERY ad request (interstitial + banner)
extras.additionalParameters = [
    "tag_for_child_directed_treatment": "1",  // COPPA compliance
    "max_ad_content_rating": "G"              // General Audiences only
]
```

### 2. **Google AdMob Console Configuration (REQUIRED)**

You MUST configure these settings in your Google AdMob account:

#### Step 1: Mark App as Child-Directed
1. Go to [AdMob Console](https://apps.admob.com/)
2. Select your app
3. Navigate to **App Settings**
4. Set **Target audience and content**:
   - **Designed for families**: ✅ YES
   - **Age groups**: 6-8 years (adjust as needed)
   - **COPPA**: Mark as child-directed
   - **Content rating**: Everyone

#### Step 2: Block Ad Categories
Navigate to **Blocking controls** and block inappropriate categories:

**Categories to BLOCK:**
- ❌ Dating & Personals
- ❌ Gambling & Betting
- ❌ Get Rich Quick
- ❌ Politics
- ❌ Religion
- ❌ Sexual & Reproductive Health
- ❌ Alcohol
- ❌ Weight Loss
- ❌ Occult/Astrology
- ❌ Weapons & Explosives
- ❌ Sensitive Social Issues
- ❌ Simulation Gaming

**Safe Categories (ALLOW):**
- ✅ Education
- ✅ Arts & Entertainment (kid-friendly)
- ✅ Books & Literature (age-appropriate)
- ✅ Food & Drink (non-alcoholic)
- ✅ Toys & Games (age-appropriate)
- ✅ Travel
- ✅ Sports (family-friendly)

#### Step 3: Enable Ad Review Center
1. Navigate to **Blocking controls** → **Ad review center**
2. Enable **Automatic ad review**
3. Set sensitivity to **High**
4. This allows you to manually review and block specific ads

#### Step 4: Sensitive Ad Categories
1. Navigate to **Blocking controls** → **Sensitive categories**
2. Block ALL sensitive categories:
   - ❌ Sensitive social issues
   - ❌ Shocking content
   - ❌ Sexually suggestive content

### 3. **App Store Requirements**

When submitting to App Store, ensure:

1. **Info.plist** includes privacy strings:
   ```xml
   <key>NSUserTrackingUsageDescription</key>
   <string>We do not track you. This is required for ad display.</string>
   ```

2. **App Store Connect** settings:
   - Primary category: **Education** or **Kids**
   - Age rating: Appropriate for target age
   - Declare ad usage in privacy section

3. **Kids Category Compliance**:
   - ✅ No behavioral advertising
   - ✅ No tracking or analytics
   - ✅ All ads marked as non-personalized
   - ✅ Parent gate before purchases

## 📋 What This Means

### Ads That WILL Show:
- ✅ Educational apps/games
- ✅ Age-appropriate entertainment
- ✅ Children's books
- ✅ Family-friendly products
- ✅ Kid-safe brands

### Ads That WILL NOT Show:
- ❌ Adult content of any kind
- ❌ Gambling or betting
- ❌ Dating services
- ❌ Alcohol or tobacco
- ❌ Violent or scary content
- ❌ Personalized/targeted ads based on user behavior

## 🛡️ Multi-Layer Protection

We use **defense in depth** with 3 layers:

1. **SDK Level**: Global configuration ensures child-directed treatment
2. **Request Level**: Every ad request explicitly requires G-rated content
3. **AdMob Console**: Manual blocking of inappropriate categories

## ⚠️ IMPORTANT: First-Time Setup Checklist

Before publishing your app, complete these steps:

- [ ] Create AdMob account
- [ ] Register app in AdMob console
- [ ] Mark app as "Designed for Families"
- [ ] Set COPPA compliance to "Yes"
- [ ] Block all inappropriate ad categories (see list above)
- [ ] Enable Ad Review Center with high sensitivity
- [ ] Test with real devices (not just simulator)
- [ ] Replace test ad unit IDs with production IDs in AdManager.swift:
  ```swift
  private let productionAdUnitID = "ca-app-pub-XXXXX/YYYYY"  // Your real ID
  private let productionBannerAdUnitID = "ca-app-pub-XXXXX/ZZZZZ"  // Your real ID
  ```
- [ ] Add GADApplicationIdentifier to Info.plist
- [ ] Submit for App Store review with Kids Category selected

## 📞 Support

If you see an inappropriate ad during testing:
1. Take a screenshot
2. Report it in AdMob Console → Ad review center
3. Block that specific ad or advertiser

## 🔗 Resources

- [Google AdMob COPPA Compliance](https://support.google.com/admob/answer/6223431)
- [Designed for Families Program](https://support.google.com/googleplay/android-developer/answer/9893335)
- [Apple Kids Category Guidelines](https://developer.apple.com/app-store/kids-apps/)
- [COPPA Compliance Guide](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)

---

**Last Updated**: January 2026
**App Version**: 1.5
