//  

import Foundation
import AppServices
import Utilities
import AppEntities

final class FamilyCheckingRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func userHasFamily() async throws -> Bool {
        guard let account = authService.account else { return false }
        let user = try await firebaseClient.getUser(account.id)
        switch user {
        case .success(let success):
            authService.updateAccount(
                .init(
                    id: success.id,
                    photoURL: success.photoURL,
                    firstName: success.firstName,
                    lastName: success.lastName,
                    familyId: success.familyId,
                    role: success.role
                ))
            return success.familyId != nil
        case .failure:
            throw FirebaseClientError.fetchingError
        }
    }
}
