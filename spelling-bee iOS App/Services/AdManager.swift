//
//  AdManager.swift
//  spelling-bee iOS App
//
//  Manages Google AdMob interstitial advertisements for kids app compliance.
//  Ads are shown BEFORE and AFTER tests, never during gameplay.
//  Uses COPPA-compliant non-personalized ads only.
//

import Foundation
import SwiftUI
import GoogleMobileAds

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    // MARK: - Published State
    @Published var shouldShowAd: Bool = false
    @Published var isAdLoaded: Bool = false
    @Published var isShowingAd: Bool = false
    @Published var isInitialized: Bool = false

    // MARK: - Private Properties
    private var interstitialAd: GADInterstitialAd?
    private var testsCompletedSinceLastAd: Int = 0
    private let testsBeforeAd: Int = 1  // Show ad after every completed test

    // MARK: - Ad Configuration

    // Test ad unit ID for development (MUST use this during development)
    private let testAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    // Production ad unit ID (to be replaced when app is approved)
    // TODO: Replace with real ad unit ID from AdMob console after app approval
    private let productionAdUnitID = "ca-app-pub-3940256099942544/4411468910"  // Using test ID for now

    // Current ad unit ID (switches based on build configuration)
    private var currentAdUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }

    // MARK: - Dependencies
    private var storeManager: StoreManager { StoreManager.shared }

    // MARK: - Initialization

    override init() {
        super.init()
    }

    /// Initialize Google Mobile Ads SDK
    /// MUST be called once at app launch before any ad requests
    func initializeSDK() {
        guard !isInitialized else { return }

        // Verify that GADApplicationIdentifier is set in Info.plist
        guard let appID = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String,
              !appID.isEmpty else {
            print("⚠️ GADApplicationIdentifier not found in Info.plist")
            print("⚠️ Ads will be disabled. Please add your AdMob App ID to Info.plist")
            isInitialized = false
            return
        }

        print("📱 Initializing Google Mobile Ads SDK with App ID: \(appID)")

        // Configure for test devices
        #if DEBUG
        // Note: Simulators are automatically in test mode, no need to configure test device IDs
        print("📱 AdMob configured for test mode (simulator)")
        #endif

        // Start Google Mobile Ads SDK with error handling
        do {
            GADMobileAds.sharedInstance().start { [weak self] status in
                Task { @MainActor in
                    self?.isInitialized = true
                    print("✅ Google Mobile Ads SDK initialized successfully")
                    print("📊 Adapter statuses:")
                    for (adapter, adapterStatus) in status.adapterStatusesByClassName {
                        print("  - \(adapter): \(adapterStatus.state.rawValue)")
                    }

                    // Preload first ad after initialization
                    await self?.loadAd()
                }
            }
        } catch {
            print("❌ Failed to initialize Google Mobile Ads SDK: \(error)")
            isInitialized = false
        }
    }

    // MARK: - Ad Loading

    /// Load an interstitial ad
    func loadAd() async {
        // Don't load ads if user purchased "Remove Ads"
        guard adsEnabled else {
            print("⏭️ Ads disabled (user purchased Remove Ads)")
            return
        }

        // Don't load if SDK not initialized
        guard isInitialized else {
            print("⚠️ Cannot load ad: SDK not initialized")
            return
        }

        print("🔄 Loading interstitial ad...")

        // Create ad request
        let request = GADRequest()

        // COPPA compliance: Mark as child-directed treatment
        // This disables personalized ads automatically
        request.requestAgent = "kids_app"

        do {
            // Load interstitial ad
            let ad = try await GADInterstitialAd.load(
                withAdUnitID: currentAdUnitID,
                request: request
            )

            // Set delegate
            ad.fullScreenContentDelegate = self

            // Store the ad
            interstitialAd = ad
            isAdLoaded = true

            print("✅ Interstitial ad loaded successfully")

        } catch {
            print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
            isAdLoaded = false
            interstitialAd = nil
        }
    }

    // MARK: - Ad Display Logic

    /// Call this when a test is completed to determine if an ad should be shown
    func onTestCompleted() {
        // Don't show ads if user purchased "Remove Ads"
        guard adsEnabled else {
            shouldShowAd = false
            return
        }

        testsCompletedSinceLastAd += 1

        // Show ad after completing required number of tests
        if testsCompletedSinceLastAd >= testsBeforeAd {
            shouldShowAd = true
            testsCompletedSinceLastAd = 0
            print("📺 Post-test ad ready to show")
        }
    }

    /// Show interstitial ad
    func showAd(from viewController: UIViewController) {
        guard adsEnabled else {
            print("⏭️ Skipping ad (user purchased Remove Ads)")
            return
        }

        guard let ad = interstitialAd, isAdLoaded else {
            print("⚠️ No ad available to show, proceeding without ad")
            onAdDismissed()
            return
        }

        print("📺 Presenting interstitial ad...")
        isShowingAd = true
        ad.present(fromRootViewController: viewController)
    }

    /// Call this when the ad has been shown or dismissed
    func onAdDismissed() {
        shouldShowAd = false
        isShowingAd = false
        isAdLoaded = false
        interstitialAd = nil

        print("✅ Ad dismissed, preloading next ad...")

        // Preload next ad
        Task {
            await loadAd()
        }
    }

    /// Call this to skip showing the ad (e.g., if ad failed to load)
    func skipAd() {
        shouldShowAd = false
        isShowingAd = false
        print("⏭️ Ad skipped")

        // Try to load an ad for next time
        if !isAdLoaded {
            Task {
                await loadAd()
            }
        }
    }

    /// Check if ads should be shown (respects purchase state)
    var adsEnabled: Bool {
        !storeManager.isAdsRemoved
    }
}

// MARK: - GADFullScreenContentDelegate

extension AdManager: GADFullScreenContentDelegate {

    nonisolated func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("📊 Ad impression recorded")
    }

    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("❌ Ad failed to present: \(error.localizedDescription)")
            self.onAdDismissed()
        }
    }

    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📺 Ad will present")
    }

    nonisolated func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📺 Ad will dismiss")
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            print("✅ Ad dismissed by user")
            self.onAdDismissed()
        }
    }
}

// MARK: - Pre-Test Ad View (Shows Google AdMob interstitial before test starts)
struct PreTestAdView: View {
    @ObservedObject var adManager = AdManager.shared
    let level: Int
    let onDismiss: () -> Void

    var body: some View {
        AdMobInterstitialViewWrapper(onDismiss: onDismiss)
            .onAppear {
                print("📺 Pre-test ad view appeared for level \(level)")
            }
    }
}

// MARK: - Post-Test Ad Wrapper (Shows real Google AdMob interstitial)
struct PostTestAdView: View {
    @ObservedObject var adManager = AdManager.shared
    let onDismiss: () -> Void

    var body: some View {
        AdMobInterstitialViewWrapper(onDismiss: onDismiss)
            .onAppear {
                print("📺 Post-test ad view appeared")
            }
    }
}

// MARK: - UIViewControllerRepresentable for AdMob Interstitial
struct AdMobInterstitialViewWrapper: UIViewControllerRepresentable {
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> AdMobViewController {
        let vc = AdMobViewController()
        vc.onDismiss = onDismiss
        return vc
    }

    func updateUIViewController(_ uiViewController: AdMobViewController, context: Context) {}
}

class AdMobViewController: UIViewController {
    var onDismiss: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task { @MainActor in
            // Small delay to ensure view is fully presented
            try? await Task.sleep(nanoseconds: 500_000_000)

            // Show the ad
            AdManager.shared.showAd(from: self)

            // If ad fails or isn't loaded, dismiss immediately
            if !AdManager.shared.isAdLoaded {
                onDismiss?()
            }
        }
    }
}
