//
//  StoreManager.swift
//  spelling-bee Watch App
//
//  Manages In-App Purchase entitlements on watchOS.
//  Purchases are made on iPhone; watch only checks entitlement status.
//

import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    // MARK: - Product IDs
    static let removeAdsProductId = "remove_ads"

    // MARK: - Published State
    @Published private(set) var isAdsRemoved: Bool = false

    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Initialization
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Check current entitlements on init
        Task {
            await checkEntitlements()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Check Entitlements

    func checkEntitlements() async {
        // Check if user has the remove_ads entitlement
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == StoreManager.removeAdsProductId {
                    isAdsRemoved = true
                    return
                }
            }
        }
        isAdsRemoved = false
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
        if transaction.productID == StoreManager.removeAdsProductId {
            await MainActor.run {
                self.isAdsRemoved = true
            }
        }
    }
}
