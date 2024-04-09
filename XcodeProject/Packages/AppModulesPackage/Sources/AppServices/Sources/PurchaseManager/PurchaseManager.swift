//

import Foundation
import StoreKit

public class PurchaseManager {
    
    private var updates: Task<Void, Never>? = nil
    private(set) var purchasedProductIDs = Set<String>()
    
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    public init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    public func getProducts(names: [String]) async throws -> [Product] {
        return try await Product.products(for: names)
    }
    
    public func purchase(
        _ product: Product,
        completionHandler: () -> Void,
        onFailure: () -> Void,
        onClose: () -> Void
    ) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
            await updatePurchasedProducts()
            completionHandler()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            onFailure()
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            onFailure()
            break
        case .userCancelled:
            onClose()
            break
        @unknown default:
            break
        }
    }
    
    public func restorePurchases(completition: () async throws -> Void) async throws {
        try await AppStore.sync()
        try await updatePurchasedProducts()
        print(purchasedProductIDs)
        if hasUnlockedPro {
            try await completition()
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}
