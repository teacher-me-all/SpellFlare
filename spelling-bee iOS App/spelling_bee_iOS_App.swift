//
//  spelling_bee_iOS_App.swift
//  spelling-bee iOS App
//
//  Main entry point for iOS spelling bee app.
//

import SwiftUI

// MARK: - UI Testing Configuration
struct UITestingConfig {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    static var shouldResetState: Bool {
        ProcessInfo.processInfo.arguments.contains("RESET_STATE")
    }

    static var hasExistingProfile: Bool {
        ProcessInfo.processInfo.arguments.contains("EXISTING_PROFILE")
    }

    static var isAdsRemoved: Bool {
        ProcessInfo.processInfo.arguments.contains("ADS_REMOVED")
    }

    static var isAdsNotRemoved: Bool {
        ProcessInfo.processInfo.arguments.contains("ADS_NOT_REMOVED")
    }

    static var simulateLevelComplete: Bool {
        ProcessInfo.processInfo.arguments.contains("SIMULATE_LEVEL_COMPLETE") ||
        ProcessInfo.processInfo.arguments.contains("LEVEL_COMPLETE_TEST")
    }
}

@main
struct spelling_bee_iOS_App: App {
    @StateObject private var appState: AppState
    @StateObject private var storeManager: StoreManager

    init() {
        // Configure for UI testing if needed
        if UITestingConfig.isUITesting {
            // Configure StoreManager for UI testing
            let store = StoreManager(uiTestingMode: true, adsRemoved: UITestingConfig.isAdsRemoved)
            _storeManager = StateObject(wrappedValue: store)

            // Configure AppState for UI testing
            let state = AppState(uiTestingMode: true,
                                 resetState: UITestingConfig.shouldResetState,
                                 existingProfile: UITestingConfig.hasExistingProfile)
            _appState = StateObject(wrappedValue: state)
        } else {
            _storeManager = StateObject(wrappedValue: StoreManager.shared)
            _appState = StateObject(wrappedValue: AppState())
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(storeManager)
                .onAppear {
                    // Pass UI testing config to appState if needed
                    if UITestingConfig.simulateLevelComplete {
                        appState.uiTestingSimulateLevelComplete = true
                    }
                }
        }
    }
}
