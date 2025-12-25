//
//  ContentView.swift
//  spelling-bee iOS App
//
//  Root navigation controller for the iOS app.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .onboarding:
                OnboardingView()
            case .home:
                HomeView()
            case .game(let level):
                GameView(level: level)
                    .id(level) // Force view recreation when level changes
            case .settings:
                SettingsView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
