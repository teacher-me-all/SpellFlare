//
//  StoreManager.swift
//  spelling-bee iOS App
//
//  Manages In-App Purchases using StoreKit 2.
//  Handles "Remove Ads" and "Unlock Watch" non-consumable purchases.
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    // MARK: - Product IDs
    static let removeAdsProductId = "remove_ads"
    static let unlockWatchProductId = "unlock_watch"

    // MARK: - Debug Mode (set to false for production)
    #if DEBUG
    private let debugMode = true  // Enable to test without StoreKit config
    #else
    private let debugMode = false
    #endif

    // MARK: - UI Testing Mode
    private let uiTestingMode: Bool

    // MARK: - Published State
    @Published private(set) var isAdsRemoved: Bool = false {
        didSet {
            // Persist debug purchase state (not in UI testing mode)
            if debugMode && !uiTestingMode {
                UserDefaults.standard.set(isAdsRemoved, forKey: "debug_ads_removed")
            }
        }
    }
    @Published private(set) var isWatchUnlocked: Bool = false {
        didSet {
            // Persist debug purchase state (not in UI testing mode)
            if debugMode && !uiTestingMode {
                UserDefaults.standard.set(isWatchUnlocked, forKey: "debug_watch_unlocked")
            }
        }
    }
    @Published private(set) var removeAdsProduct: Product?
    @Published private(set) var unlockWatchProduct: Product?
    @Published private(set) var purchaseInProgress: Bool = false
    @Published private(set) var purchaseError: String?

    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Initialization

    /// Standard initializer for production use
    init() {
        self.uiTestingMode = false

        // Load debug state if in debug mode
        if debugMode {
            isAdsRemoved = UserDefaults.standard.bool(forKey: "debug_ads_removed")
            isWatchUnlocked = UserDefaults.standard.bool(forKey: "debug_watch_unlocked")
        }

        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Check current entitlements on init
        Task {
            await checkEntitlements()
            await loadProducts()
        }
    }

    /// UI Testing initializer - allows configuring ads removed state
    /// - Parameters:
    ///   - uiTestingMode: When true, skips StoreKit operations
    ///   - adsRemoved: Initial state for isAdsRemoved in UI testing mode
    init(uiTestingMode: Bool, adsRemoved: Bool) {
        self.uiTestingMode = uiTestingMode

        if uiTestingMode {
            // In UI testing mode, set the ads state directly without StoreKit
            self.isAdsRemoved = adsRemoved
            // Don't start transaction listener or load products in UI testing mode
        } else {
            // Normal initialization
            if debugMode {
                isAdsRemoved = UserDefaults.standard.bool(forKey: "debug_ads_removed")
                isWatchUnlocked = UserDefaults.standard.bool(forKey: "debug_watch_unlocked")
            }
            updateListenerTask = listenForTransactions()
            Task {
                await checkEntitlements()
                await loadProducts()
            }
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [
                StoreManager.removeAdsProductId,
                StoreManager.unlockWatchProductId
            ])
            for product in products {
                switch product.id {
                case StoreManager.removeAdsProductId:
                    removeAdsProduct = product
                case StoreManager.unlockWatchProductId:
                    unlockWatchProduct = product
                default:
                    break
                }
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Check Entitlements

    func checkEntitlements() async {
        var foundAdsRemoved = false
        var foundWatchUnlocked = false

        // Check all current entitlements
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                switch transaction.productID {
                case StoreManager.removeAdsProductId:
                    foundAdsRemoved = true
                case StoreManager.unlockWatchProductId:
                    foundWatchUnlocked = true
                default:
                    break
                }
            }
        }

        isAdsRemoved = foundAdsRemoved
        isWatchUnlocked = foundWatchUnlocked
    }

    // MARK: - Purchase Remove Ads

    func purchaseRemoveAds() async -> Bool {
        // Debug mode: simulate purchase without StoreKit
        if debugMode {
            purchaseInProgress = true
            purchaseError = nil
            // Simulate brief delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            isAdsRemoved = true
            purchaseInProgress = false
            return true
        }

        guard let product = removeAdsProduct else {
            purchaseError = "Product not available. Please try again later."
            return false
        }

        purchaseInProgress = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction cryptographically
                if case .verified(let transaction) = verification {
                    // Grant entitlement
                    isAdsRemoved = true
                    // Finish the transaction
                    await transaction.finish()
                    purchaseInProgress = false
                    return true
                } else {
                    // Verification failed - do not grant entitlement
                    purchaseError = "Purchase verification failed"
                    purchaseInProgress = false
                    return false
                }

            case .userCancelled:
                purchaseInProgress = false
                return false

            case .pending:
                purchaseError = "Purchase pending approval"
                purchaseInProgress = false
                return false

            @unknown default:
                purchaseError = "Unknown purchase result"
                purchaseInProgress = false
                return false
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            purchaseInProgress = false
            return false
        }
    }

    // MARK: - Purchase Unlock Watch

    func purchaseUnlockWatch() async -> Bool {
        // Debug mode: simulate purchase without StoreKit
        if debugMode {
            purchaseInProgress = true
            purchaseError = nil
            // Simulate brief delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            isWatchUnlocked = true
            purchaseInProgress = false
            // Sync Watch unlock state
            PhoneSyncHelper.shared.syncWatchUnlockState()
            return true
        }

        guard let product = unlockWatchProduct else {
            purchaseError = "Product not available. Please try again later."
            return false
        }

        purchaseInProgress = true
        purchaseError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Verify the transaction cryptographically
                if case .verified(let transaction) = verification {
                    // Grant entitlement
                    isWatchUnlocked = true
                    // Finish the transaction
                    await transaction.finish()
                    purchaseInProgress = false

                    // Sync Watch unlock state
                    PhoneSyncHelper.shared.syncWatchUnlockState()

                    return true
                } else {
                    // Verification failed - do not grant entitlement
                    purchaseError = "Purchase verification failed"
                    purchaseInProgress = false
                    return false
                }

            case .userCancelled:
                purchaseInProgress = false
                return false

            case .pending:
                purchaseError = "Purchase pending approval"
                purchaseInProgress = false
                return false

            @unknown default:
                purchaseError = "Unknown purchase result"
                purchaseInProgress = false
                return false
            }
        } catch {
            purchaseError = "Purchase failed: \(error.localizedDescription)"
            purchaseInProgress = false
            return false
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await checkEntitlements()

            // Sync Watch unlock state if restored
            if isWatchUnlocked {
                PhoneSyncHelper.shared.syncWatchUnlockState()
            }

            return isAdsRemoved || isWatchUnlocked
        } catch {
            purchaseError = "Restore failed: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.handleVerifiedTransaction(transaction)
                    await transaction.finish()
                }
            }
        }
    }

    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        switch transaction.productID {
        case StoreManager.removeAdsProductId:
            await MainActor.run {
                self.isAdsRemoved = true
            }
        case StoreManager.unlockWatchProductId:
            await MainActor.run {
                self.isWatchUnlocked = true
                // Sync Watch unlock state
                PhoneSyncHelper.shared.syncWatchUnlockState()
            }
        default:
            break
        }
    }

    // MARK: - Formatted Prices

    var formattedRemoveAdsPrice: String {
        removeAdsProduct?.displayPrice ?? "$0.99"
    }

    var formattedUnlockWatchPrice: String {
        unlockWatchProduct?.displayPrice ?? "$0.99"
    }

    // Legacy compatibility
    var formattedPrice: String {
        formattedRemoveAdsPrice
    }
}
