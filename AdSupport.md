Advertising Configuration Requirements (AdMob) — iPhone App Only
1. Scope & Platform

The app is an iPhone-only application.

All advertising functionality applies only to the iOS app.

There are no watchOS constraints in this configuration.

2. Ad Network Selection

Use Google AdMob as the advertising platform.

Integrate Google Mobile Ads SDK for iOS.

No other ad networks should be used.

3. Ad Types to Support

Interstitial ads ONLY

No banner ads

No rewarded ads (unless explicitly added later)

Interstitial ads must be shown:

When the spelling bee game starts

Optionally between levels (if added later)

4. Development vs Production Configuration
4.1 Development Mode (MANDATORY)

During development and testing:

Use Google’s official test ad unit IDs

Never use real ad unit IDs

Test Interstitial Ad Unit ID (iOS):

ca-app-pub-3940256099942544/4411468910


Configure test devices:

GADMobileAds.sharedInstance()
  .requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]

4.2 Production Mode

Production ad unit IDs must:

Be configurable (not hardcoded)

Be easy to switch without code changes

Production ads must only be enabled after AdMob app approval

5. SDK Initialization (MANDATORY)

Initialize Google Mobile Ads SDK once at app launch:

GADMobileAds.sharedInstance().start(completionHandler: nil)


Initialization must occur before any ad request.

6. iOS Configuration Requirements (Info.plist)
6.1 SKAdNetwork Configuration (MANDATORY)

Add the following to the iOS app’s Info.plist:

<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>


Without this, ads may fail silently.

6.2 App Transport Security (ATS)

Ensure HTTPS traffic is allowed for ads:

<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>

7. Ad Presentation Flow
Required Flow

User starts the spelling bee game

Interstitial ad is requested and displayed

After the ad is dismissed:

The game begins immediately

8. Failure & Edge Case Handling

If an ad fails to load:

Log the error

Proceed with gameplay immediately

Ads must NEVER:

Block gameplay

Cause crashes

Leave the app in a stuck state

9. Logging & Debugging

Enable AdMob debug logging in development builds

Log:

Ad load success

Ad load failure

“No fill” responses

10. Architecture Expectations

Create a dedicated AdService / AdManager responsible for:

SDK initialization

Loading interstitial ads

Presenting ads

UI code must NOT directly manage AdMob logic

Ads must be triggered via a clean API (e.g. showAdIfAvailable())

11. Kids App Compliance (IMPORTANT)

Ads must be:

Non-personalized

COPPA-compliant

Disable personalized ads:

let request = GADRequest()
request.requestAgent = "kids_app"

12. Validation Criteria

The implementation is correct only if:

✔ Ads appear using test ads in development
✔ Ads appear reliably after SDK initialization
✔ Game starts even if ads fail
✔ No crashes or UI blocking
✔ Ad logic is centralized and maintainable

13. Explicit Non-Goals

No banner ads

No rewarded ads

No third-party ad networks

✅ Success Definition

Ads reliably appear at game start

Gameplay is never blocked

Implementation is clean, testable, and compliant with kids app policies
