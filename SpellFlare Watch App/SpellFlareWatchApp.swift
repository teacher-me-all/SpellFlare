//
//  SpellFlareWatchApp.swift
//  SpellFlare Watch App
//
//  Main entry point for the watchOS app.
//

import SwiftUI

@main
struct SpellFlareWatchApp: App {
    @StateObject private var appState = WatchAppState()
    @StateObject private var syncHelper = WatchSyncHelper.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(syncHelper)
                .onAppear {
                    syncHelper.requestProfile()
                }
        }
    }
}
