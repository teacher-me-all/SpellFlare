//
//  AppState.swift
//  spelling-bee iOS App
//
//  Global application state and navigation.
//

import Foundation
import SwiftUI
import Combine

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
    @Published private(set) var syncStatus: SyncStatus = .idle

    // MARK: - UI Testing Properties
    /// When true, GameViewModel should simulate immediate level completion
    var uiTestingSimulateLevelComplete: Bool = false
    private let uiTestingMode: Bool

    private let persistence = PersistenceService.shared
    private let phoneSyncHelper = PhoneSyncHelper.shared
    private let gameCenterService = GameCenterService.shared
    private var cancellables = Set<AnyCancellable>()

    /// Standard initializer for production use
    init() {
        self.uiTestingMode = false
        setupSyncObserver()
        loadProfile()

        // Authenticate with Game Center for cloud backup
        Task {
            await gameCenterService.authenticate()
        }
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
            setupSyncObserver()
            loadProfile()
        }
    }

    private func setupSyncObserver() {
        phoneSyncHelper.$syncStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.syncStatus = status
            }
            .store(in: &cancellables)
    }

    func loadProfile() {
        // Skip persistence in UI testing mode
        if uiTestingMode {
            return
        }

        if var savedProfile = persistence.loadProfile() {
            // Run coins migration for existing users
            if !savedProfile.coinsMigrationCompleted {
                CoinsService.shared.migrateExistingProgress(profile: &savedProfile)
                persistence.saveProfile(savedProfile)
            }
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
            phoneSyncHelper.pushLocalChanges()
        }
        currentScreen = .home
    }

    func updateGrade(_ grade: Int) {
        profile?.grade = grade
        if let profile = profile, !uiTestingMode {
            persistence.saveProfile(profile)
            phoneSyncHelper.pushLocalChanges()
        }
    }

    func completeLevel(_ level: Int) {
        profile?.completeLevel(level)
        if let profile = profile, !uiTestingMode {
            persistence.saveProfile(profile)
            phoneSyncHelper.pushLocalChanges()
        }
    }

    /// Award coins to the user and save profile
    /// - Parameter amount: Number of coins to award
    func awardCoins(_ amount: Int) {
        guard var currentProfile = profile else { return }
        CoinsService.shared.awardCoins(amount, to: &currentProfile)
        profile = currentProfile
        if !uiTestingMode {
            persistence.saveProfile(currentProfile)
            phoneSyncHelper.pushLocalChanges()
        }
    }

    /// Complete a level and award coins in one operation
    /// - Parameters:
    ///   - level: The level completed
    ///   - coinsEarned: Coins to award for this level
    func completeLevelWithCoins(_ level: Int, coinsEarned: Int) {
        profile?.completeLevel(level)
        if var currentProfile = profile {
            CoinsService.shared.awardCoins(coinsEarned, to: &currentProfile)
            profile = currentProfile
            if !uiTestingMode {
                persistence.saveProfile(currentProfile)
                phoneSyncHelper.pushLocalChanges()

                // Backup to Game Center cloud
                Task {
                    await gameCenterService.backupCurrentProfile()
                }
            }
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
            SyncCoordinator.shared.deleteAllData()
        }
        profile = nil
        currentScreen = .onboarding
    }

    // MARK: - Sync Triggers

    func onAppBecameActive() {
        guard !uiTestingMode else { return }
        phoneSyncHelper.syncOnAppear()

        // Reload profile after sync
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5s for sync
            await MainActor.run {
                if let syncedProfile = persistence.loadProfile() {
                    self.profile = syncedProfile
                }
            }

            // Try to restore from Game Center if better data available
            if await gameCenterService.restoreAndApplyIfBetter() {
                await MainActor.run {
                    if let restoredProfile = persistence.loadProfile() {
                        self.profile = restoredProfile
                        print("Applied Game Center cloud profile")
                    }
                }
            }
        }
    }
}
