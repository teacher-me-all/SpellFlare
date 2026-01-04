# Spellflare - Session Backup

This document contains all changes made during the development session on 2026-01-01. Use this to recreate the work on a different device.

---

## Summary of Changes

1. **Progress Sharing (WatchConnectivity only)** - Sync between iPhone and Watch without CloudKit
2. **App Renamed** - "Spelling Bee Queen" → "Spellflare"
3. **Version Updated** - 1.0 → 1.1
4. **Watch App Removed** - iOS-only app now

---

## 1. Progress Sharing Implementation

### Architecture
- **No CloudKit** (requires paid developer account)
- **WatchConnectivity only** - Direct sync between paired iPhone and Watch
- Sync triggers: app becomes active, level completed, profile created/updated

### New Files Created

#### `Shared/Models/SyncableProfile.swift`
```swift
//
//  SyncableProfile.swift
//  Shared
//
//  A wrapper around UserProfile that includes sync metadata.
//

import Foundation

struct SyncableProfile: Codable {
    var profile: UserProfile
    var lastModified: Date
    var deviceId: String

    init(profile: UserProfile) {
        self.profile = profile
        self.lastModified = Date()
        self.deviceId = Self.currentDeviceId
    }

    static var currentDeviceId: String {
        #if os(watchOS)
        return "watch-\(UUID().uuidString.prefix(8))"
        #else
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        #endif
    }

    /// Merge two profiles, keeping the most recent data
    static func merge(local: SyncableProfile, remote: SyncableProfile) -> SyncableProfile {
        // Use the one with more completed levels, or if equal, the most recent
        let localLevels = local.profile.completedLevels.count
        let remoteLevels = remote.profile.completedLevels.count

        if localLevels > remoteLevels {
            return local
        } else if remoteLevels > localLevels {
            return remote
        } else {
            // Same number of levels - use most recent
            return local.lastModified > remote.lastModified ? local : remote
        }
    }
}
```

#### `Shared/Protocols/SyncServiceProtocol.swift`
```swift
//
//  SyncServiceProtocol.swift
//  Shared
//
//  Protocol for sync services.
//

import Foundation

enum SyncStatus: Equatable {
    case idle
    case syncing
    case success
    case error(String)
}

protocol SyncServiceProtocol {
    func save(_ profile: SyncableProfile) async throws
    func fetch() async throws -> SyncableProfile?
    func delete() async throws
}
```

#### `Shared/Services/LocalCacheService.swift`
```swift
//
//  LocalCacheService.swift
//  Shared
//
//  Handles local caching of user profile with sync metadata.
//

import Foundation

class LocalCacheService {
    static let shared = LocalCacheService()

    private let userDefaults = UserDefaults.standard
    private let profileKey = "syncable_profile"
    private let lastSyncKey = "last_sync_date"
    private let pendingSyncKey = "pending_sync"

    private init() {}

    // MARK: - Syncable Profile

    func saveSyncableProfile(_ profile: SyncableProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            userDefaults.set(data, forKey: profileKey)
            markPendingSync()
        }
    }

    func loadSyncableProfile() -> SyncableProfile? {
        guard let data = userDefaults.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(SyncableProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    // MARK: - UserProfile (convenience)

    func saveProfile(_ profile: UserProfile) {
        let syncable = SyncableProfile(profile: profile)
        saveSyncableProfile(syncable)
    }

    func loadProfile() -> UserProfile? {
        return loadSyncableProfile()?.profile
    }

    // MARK: - Sync Status

    var lastSyncDate: Date? {
        get { userDefaults.object(forKey: lastSyncKey) as? Date }
        set { userDefaults.set(newValue, forKey: lastSyncKey) }
    }

    var hasPendingSync: Bool {
        get { userDefaults.bool(forKey: pendingSyncKey) }
        set { userDefaults.set(newValue, forKey: pendingSyncKey) }
    }

    func markPendingSync() {
        hasPendingSync = true
    }

    func clearPendingSync() {
        hasPendingSync = false
        lastSyncDate = Date()
    }

    // MARK: - Clear All

    func clearAll() {
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.removeObject(forKey: lastSyncKey)
        userDefaults.removeObject(forKey: pendingSyncKey)
    }
}
```

#### `Shared/Services/SyncCoordinator.swift`
```swift
//
//  SyncCoordinator.swift
//  Shared
//
//  Orchestrates local cache operations.
//  Sync between devices is handled by PhoneSyncHelper (iOS) and WatchSyncHelper (watchOS).
//

import Foundation
import Combine

@MainActor
class SyncCoordinator: ObservableObject {
    static let shared = SyncCoordinator()

    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date?

    private let localCache = LocalCacheService.shared

    private init() {
        lastSyncDate = localCache.lastSyncDate
    }

    // MARK: - Profile Access

    func loadProfile() -> UserProfile? {
        return localCache.loadProfile()
    }

    func saveProfile(_ profile: UserProfile) {
        localCache.saveProfile(profile)
    }

    // MARK: - Reset

    func deleteAllData() {
        localCache.clearAll()
    }
}
```

#### `spelling-bee iOS App/Services/PhoneSyncHelper.swift`
```swift
//
//  PhoneSyncHelper.swift
//  spelling-bee iOS App
//
//  Handles phone-to-watch sync via WatchConnectivity.
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
class PhoneSyncHelper: NSObject, ObservableObject {
    static let shared = PhoneSyncHelper()

    @Published private(set) var isWatchReachable = false
    @Published private(set) var syncStatus: SyncStatus = .idle

    private let session: WCSession
    private let localCache = LocalCacheService.shared

    private override init() {
        self.session = WCSession.default
        super.init()

        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - Sync Methods

    /// Called when app becomes active - request profile from Watch if needed
    func syncOnAppear() {
        guard session.isReachable else {
            syncStatus = .idle
            return
        }

        syncStatus = .syncing

        // Request profile from Watch to merge
        session.sendMessage(
            ["action": "requestProfile"],
            replyHandler: { [weak self] reply in
                Task { @MainActor in
                    self?.handleProfileReply(reply)
                }
            },
            errorHandler: { [weak self] error in
                Task { @MainActor in
                    print("Watch sync error: \(error)")
                    self?.syncStatus = .error(error.localizedDescription)
                }
            }
        )
    }

    private func handleProfileReply(_ reply: [String: Any]) {
        if let profileData = reply["profile"] as? Data,
           let remoteProfile = try? JSONDecoder().decode(SyncableProfile.self, from: profileData) {

            // Merge with local
            if let local = localCache.loadSyncableProfile() {
                let merged = SyncableProfile.merge(local: local, remote: remoteProfile)
                localCache.saveSyncableProfile(merged)

                // If local was newer, send it to Watch
                if merged.lastModified == local.lastModified {
                    sendProfileToWatch(local)
                }
            } else {
                // No local profile, use remote
                localCache.saveSyncableProfile(remoteProfile)
            }

            syncStatus = .success
        } else if reply["noProfile"] as? Bool == true {
            // Watch has no profile, send ours if we have one
            if let local = localCache.loadSyncableProfile() {
                sendProfileToWatch(local)
            }
            syncStatus = .success
        } else {
            syncStatus = .idle
        }
    }

    /// Send profile to Watch
    func sendProfileToWatch(_ profile: SyncableProfile) {
        guard session.isReachable else { return }

        guard let data = try? JSONEncoder().encode(profile) else { return }

        session.sendMessage(
            ["action": "profileUpdated", "profile": data],
            replyHandler: nil,
            errorHandler: { error in
                print("Failed to send profile to Watch: \(error)")
            }
        )
    }

    /// Called after local profile changes - push to Watch
    func pushLocalChanges() {
        if let local = localCache.loadSyncableProfile(), session.isReachable {
            sendProfileToWatch(local)
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneSyncHelper: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            isWatchReachable = session.isReachable
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        // Required for iOS
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Required for iOS - reactivate session
        session.activate()
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isWatchReachable = session.isReachable
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            handleReceivedMessage(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            handleReceivedMessage(message, replyHandler: replyHandler)
        }
    }

    @MainActor
    private func handleReceivedMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        if let action = message["action"] as? String {
            switch action {
            case "requestSync":
                // Watch is requesting our profile
                if let local = localCache.loadSyncableProfile(),
                   let data = try? JSONEncoder().encode(local) {
                    replyHandler?(["profile": data])
                } else {
                    replyHandler?(["noProfile": true])
                }

            case "updateProfile":
                // Watch pushed an updated profile
                if let profileData = message["profile"] as? Data,
                   let remoteProfile = try? JSONDecoder().decode(SyncableProfile.self, from: profileData) {

                    if let local = localCache.loadSyncableProfile() {
                        let merged = SyncableProfile.merge(local: local, remote: remoteProfile)
                        localCache.saveSyncableProfile(merged)
                    } else {
                        localCache.saveSyncableProfile(remoteProfile)
                    }
                }

            case "requestProfile":
                // Watch is asking for our profile
                if let local = localCache.loadSyncableProfile(),
                   let data = try? JSONEncoder().encode(local) {
                    replyHandler?(["profile": data])
                } else {
                    replyHandler?(["noProfile": true])
                }

            default:
                break
            }
        }
    }
}
```

### Modified Files

#### `spelling-bee iOS App/ViewModels/AppState.swift`
Key changes:
- Replace `syncCoordinator` with `phoneSyncHelper = PhoneSyncHelper.shared`
- In `setupSyncObserver()`: observe `phoneSyncHelper.$syncStatus`
- In `createProfile()`, `updateGrade()`, `completeLevel()`: call `phoneSyncHelper.pushLocalChanges()`
- In `onAppBecameActive()`: call `phoneSyncHelper.syncOnAppear()`
- In `resetApp()`: call `SyncCoordinator.shared.deleteAllData()` (not async)

#### `spelling-bee iOS App/spelling_bee_iOS_App.swift`
Change onChange syntax for iOS 16 compatibility:
```swift
// Before (iOS 17+)
.onChange(of: scenePhase) { _, newPhase in

// After (iOS 16)
.onChange(of: scenePhase) { newPhase in
```

---

## 2. App Rename: Spelling Bee Queen → Spellflare

### Build Settings (project.pbxproj)
Update all targets:
```
INFOPLIST_KEY_CFBundleDisplayName = Spellflare;
INFOPLIST_KEY_NSMicrophoneUsageDescription = "Spellflare uses the microphone to listen to your spelling";
INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "Spellflare needs to hear you spell words";
```

### Code Changes

#### `spelling-bee iOS App/Views/Onboarding/OnboardingView.swift`
```swift
// In WelcomeStep
Text("🐝")
    .font(.system(size: 100))

Text("Spellflare")
    .font(.largeTitle)
    .fontWeight(.bold)
    .foregroundColor(.orange)
```

#### `spelling-bee iOS App/Services/AdManager.swift`
```swift
// In PlaceholderAdView
Text("🐝")
    .font(.system(size: 60))

Text("Spellflare")
    .font(.title2)
    .fontWeight(.bold)
    .foregroundColor(.white)

// In PreTestAdView
// Bee mascot
Text("🐝")
    .font(.system(size: 70))
```

---

## 3. Version Update

### Build Settings (project.pbxproj)
Update all targets:
```
MARKETING_VERSION = 1.1;
```

---

## 4. Watch App Removal

### Deleted Folders
- `spelling-bee Watch App/`
- `spelling-bee Watch AppTests/`
- `spelling-bee Watch AppUITests/`

### Xcode Cleanup (Manual)
After opening in Xcode, remove these targets:
1. "spelling-bee" (container app)
2. "spelling-bee Watch App"
3. "spelling-bee Watch AppTests"
4. "spelling-bee Watch AppUITests"

Delete red (missing) folder references in Navigator.

---

## 5. Entitlements (Cleared)

Both entitlement files were cleared since CloudKit is not used:

#### `spelling-bee iOS App/spelling-bee-iOS.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
```

---

## File Structure After Changes

```
spelling-bee/
├── spelling-bee.xcodeproj/
├── spelling-bee iOS App/
│   ├── spelling_bee_iOS_App.swift
│   ├── ContentView.swift
│   ├── spelling-bee-iOS.entitlements
│   ├── Models/
│   │   ├── UserProfile.swift
│   │   └── Word.swift
│   ├── Services/
│   │   ├── SpeechService.swift
│   │   ├── WordBankService.swift
│   │   ├── PersistenceService.swift
│   │   ├── StoreManager.swift
│   │   ├── AdManager.swift
│   │   └── PhoneSyncHelper.swift      ← NEW
│   ├── ViewModels/
│   │   ├── AppState.swift             ← MODIFIED
│   │   └── GameViewModel.swift
│   └── Views/
│       ├── Onboarding/OnboardingView.swift  ← MODIFIED
│       ├── Home/
│       ├── Game/
│       └── Common/
├── Shared/                             ← NEW FOLDER
│   ├── Models/
│   │   └── SyncableProfile.swift
│   ├── Protocols/
│   │   └── SyncServiceProtocol.swift
│   └── Services/
│       ├── LocalCacheService.swift
│       └── SyncCoordinator.swift
├── spelling-bee iOS AppTests/
├── spelling-bee iOS AppUITests/
├── CLAUDE.md
└── SESSION_BACKUP.md                   ← THIS FILE
```

---

## Build Commands

```bash
# Build iOS App
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project spelling-bee.xcodeproj \
  -target "spelling-bee iOS App" \
  -sdk iphonesimulator \
  build

# Or with scheme (if available)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project spelling-bee.xcodeproj \
  -scheme "spelling-bee iOS App" \
  -destination 'platform=iOS Simulator,name=iPhone 14 Pro' \
  build
```

---

## Quick Recreation Steps

1. **Add Shared folder** to project with files above
2. **Add PhoneSyncHelper.swift** to iOS App/Services
3. **Update AppState.swift** to use PhoneSyncHelper
4. **Fix onChange syntax** in app entry point for iOS 16
5. **Update display names** in build settings to "Spellflare"
6. **Update version** to 1.1 in build settings
7. **Update OnboardingView** text to "Spellflare"
8. **Update AdManager** text to "Spellflare"
9. **Clear entitlements** files
10. **Delete Watch App** folders and targets (if iOS-only)

---

## Notes

- **No paid developer account needed** - CloudKit removed
- **WatchConnectivity** works with free account for iPhone ↔ Watch sync
- **Bee emoji (🐝) kept** as app mascot, only name changed to Spellflare
