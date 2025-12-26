//
//  AppState.swift
//  spelling-bee iOS App
//
//  Global application state and navigation.
//

import Foundation
import SwiftUI

enum AppScreen: Equatable {
    case onboarding
    case home
    case game(level: Int)
    case settings
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .onboarding
    @Published var profile: UserProfile?

    // MARK: - UI Testing Properties
    /// When true, GameViewModel should simulate immediate level completion
    var uiTestingSimulateLevelComplete: Bool = false
    private let uiTestingMode: Bool

    private let persistence = PersistenceService.shared

    /// Standard initializer for production use
    init() {
        self.uiTestingMode = false
        loadProfile()
    }

    /// UI Testing initializer - allows configuring initial state
    /// - Parameters:
    ///   - uiTestingMode: When true, uses test configuration instead of persistence
    ///   - resetState: When true, shows onboarding (fresh state)
    ///   - existingProfile: When true, creates a test profile and goes to home
    init(uiTestingMode: Bool, resetState: Bool, existingProfile: Bool) {
        self.uiTestingMode = uiTestingMode

        if uiTestingMode {
            if resetState {
                // Fresh state - show onboarding
                currentScreen = .onboarding
                profile = nil
            } else if existingProfile {
                // Create a test profile
                profile = UserProfile(name: "TestUser", grade: 3)
                currentScreen = .home
            } else {
                // Default: try to load existing profile
                loadProfile()
            }
        } else {
            loadProfile()
        }
    }

    func loadProfile() {
        // Skip persistence in UI testing mode
        if uiTestingMode {
            return
        }

        if let savedProfile = persistence.loadProfile() {
            profile = savedProfile
            currentScreen = .home
        } else {
            currentScreen = .onboarding
        }
    }

    func createProfile(name: String, grade: Int) {
        let newProfile = UserProfile(name: name, grade: grade)
        profile = newProfile
        if !uiTestingMode {
            persistence.saveProfile(newProfile)
        }
        currentScreen = .home
    }

    func updateGrade(_ grade: Int) {
        profile?.grade = grade
        if let profile = profile, !uiTestingMode {
            persistence.saveProfile(profile)
        }
    }

    func completeLevel(_ level: Int) {
        profile?.completeLevel(level)
        if let profile = profile, !uiTestingMode {
            persistence.saveProfile(profile)
        }
    }

    func navigateToHome() {
        currentScreen = .home
    }

    func navigateToGame(level: Int) {
        currentScreen = .game(level: level)
    }

    func navigateToSettings() {
        currentScreen = .settings
    }

    func resetApp() {
        if !uiTestingMode {
            persistence.deleteProfile()
        }
        profile = nil
        currentScreen = .onboarding
    }
}
