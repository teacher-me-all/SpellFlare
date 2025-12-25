//
//  ContentView.swift
//  spelling-bee Watch App
//
//  Root navigation view that manages screen transitions.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack {
            // Purple Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.9),
                    Color(red: 0.5, green: 0.3, blue: 0.95),
                    Color(red: 0.45, green: 0.25, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if appState.isLoading {
                    LoadingView()
                } else {
                    switch appState.currentScreen {
                    case .onboarding:
                        OnboardingView()
                            .environmentObject(appState)

                    case .home:
                        HomeView()
                            .environmentObject(appState)

                    case .game(let level):
                        GameView(level: level)
                            .environmentObject(appState)
                            .id(level) // Force view recreation when level changes

                    case .settings:
                        SettingsView()
                            .environmentObject(appState)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.currentScreen == .onboarding)
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🐝")
                .font(.system(size: 50))

            ProgressView()
                .tint(.cyan)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - AppScreen Equatable for animation
extension AppScreen: Equatable {
    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.onboarding, .onboarding),
             (.home, .home),
             (.settings, .settings):
            return true
        case (.game(let l1), .game(let l2)):
            return l1 == l2
        default:
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
