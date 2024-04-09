//

import Foundation
import AppServices
import Utilities
import StoreKit

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
    
    func getCurrentUserInfo() -> UserInfo? {
        self.authService.account
    }
    
    func getProduct() async throws -> Product? {
        try await purchaseManager.getProducts(names: ["premiumstatus"]).first
    }
    
    func purchase(_ product: Product, completionHandler: () -> Void) async throws {
        try await purchaseManager.purchase(product, completionHandler: completionHandler)
    }
    
    func setPro() async throws {
        guard let userId = authService.account?.id else { return }
        try await firebaseClient.setProStatus(userId: userId)
        defaultsStorage.add(object: true, forKey: "isPro")
    }
}
