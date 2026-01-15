//
//  ContentView.swift
//  SpellFlare Watch App
//
//  Root navigation view for the Watch app.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: WatchAppState
    @EnvironmentObject var syncHelper: WatchSyncHelper

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .loading:
                LoadingView()

            case .home:
                WatchHomeView()

            case .game(let level):
                WatchGameView(level: level)
                    .id(level)  // Force recreation when level changes

            case .levelComplete(let level, let score):
                WatchLevelCompleteView(level: level, score: score)
            }
        }
        .onChange(of: syncHelper.profile) { newProfile in
            if newProfile != nil && appState.currentScreen == .loading {
                appState.currentScreen = .home
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchAppState())
        .environmentObject(WatchSyncHelper.shared)
}
