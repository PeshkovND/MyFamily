//  

import Foundation
import AppServices
import Utilities
import AppEntities

final class AddFamilyRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func addFamily(name: String) async throws {
        guard let account = authService.account else { return }
        let familyId = UUID()
        try await firebaseClient.addFamily(.init(id: familyId, name: name))
        try await firebaseClient.updateUser(.init(
            id: account.id,
            photoURL: account.photoURL,
            firstName: account.firstName,
            lastName: account.lastName,
            familyId: familyId.uuidString
        ))
        authService.updateAccount(.init(
            id: account.id,
            photoURL: account.photoURL,
            firstName: account.firstName,
            lastName: account.lastName,
            familyId: familyId.uuidString
        ))
    }
}
