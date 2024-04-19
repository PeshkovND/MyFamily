//

import Foundation
import AppServices
import Utilities
import StoreKit
import AppEntities

final class GetProRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    private let purchaseManager: PurchaseManager
    private let defaultsStorage: DefaultsStorage
    
    init(
        firebaseClient: FirebaseClient,
        authService: AuthService,
        swiftDataManager: SwiftDataManager,
        purchaseManager: PurchaseManager,
        defaultsStorage: DefaultsStorage
    ) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
        self.purchaseManager = purchaseManager
        self.defaultsStorage = defaultsStorage
    }
    
    func getCurrentUserInfo() -> Account? {
        self.authService.account
    }
    
    func getProduct() async throws -> Product? {
        try await purchaseManager.getProducts(names: ["premiumstatus"]).first
    }
    
    func purchase(
        _ product: Product,
        completionHandler: () -> Void,
        onFailure: () -> Void,
        onClose: () -> Void
    ) async throws {
        try await purchaseManager.purchase(
            product,
            completionHandler: completionHandler,
            onFailure: onFailure,
            onClose: onClose
        )
    }
    
    func restorePurchases(completionHandler: () async throws -> Void) async throws {
        try await purchaseManager.restorePurchases(completition: completionHandler)
    }
    
    func setPro() async throws {
        guard let userId = authService.account?.id else { return }
        try await firebaseClient.setProStatus(userId: userId, status: true)
        defaultsStorage.add(object: true, forKey: "isPro")
    }
}
