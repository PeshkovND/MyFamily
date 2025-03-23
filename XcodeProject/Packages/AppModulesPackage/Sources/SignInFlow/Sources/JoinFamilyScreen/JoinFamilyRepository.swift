//  

import Foundation
import AppServices
import Utilities
import AppEntities

final class JoinFamilyRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func joinFamily(code: String) async throws {
        guard let account = authService.account else { throw AppError.unathorized }
        let invitation = try await firebaseClient.getInvitation(code)
        switch invitation {
        case .success(let success):
            try await firebaseClient.updateUser(.init(
                id: account.id,
                photoURL: account.photoURL,
                firstName: account.firstName,
                lastName: account.lastName,
                familyId: success.familyId,
                role: .regular
            ))
            authService.updateAccount(.init(
                id: account.id,
                photoURL: account.photoURL,
                firstName: account.firstName,
                lastName: account.lastName,
                familyId: success.familyId,
                role: .regular
            ))
        case .failure(let failure):
            throw failure
        }
    }
}
