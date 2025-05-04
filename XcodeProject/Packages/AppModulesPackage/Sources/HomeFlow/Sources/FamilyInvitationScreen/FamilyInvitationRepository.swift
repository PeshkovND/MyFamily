import Foundation
import AppServices
import Utilities
import AppEntities

final class FamilyInvitationRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getInvitations() async throws -> [FamilyInvitationViewData] {
        do {
            guard let familyId = authService.account?.familyId else { return [] }
            let invites = try await firebaseClient.getInvitations(familyId: familyId)
            switch invites {
            case .success(let success):
                return success.map { FamilyInvitationViewData(id: $0.id, dateCreated: makeDate($0.dateCreated)) }
            case .failure:
                throw FirebaseClientError.fetchingError
            }
        } catch let e {
            throw e
        }
    }
    
    func addInvitation() async throws -> FamilyInvitationViewData {
        let dateFormatter = AppDateFormatter()
        guard let familyId = authService.account?.familyId, let date = dateFormatter.toServerFormat(Date()) else { throw AppError.unathorized }
        let inviteCode = generateUniqueInviteCode()
        try await firebaseClient.addInvitations(invitePayload: .init(
            id: inviteCode,
            dateCreated: date,
            familyId: familyId
        ))
        return .init(id: inviteCode, dateCreated: makeDate(date))
    }
    
    func deleteInvitation(id: String) async throws {
        try await firebaseClient.deleteInvitations(id: id)
    }
    
    private func generateUniqueInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let code = String((0..<8).map { _ in letters.randomElement() ?? Character("A") })
        
        return code
    }
    
    private func makeDate(_ doubleDate: Double) -> String {
        let dateFormatter = AppDateFormatter()
        guard let date = dateFormatter.toDate(doubleDate) else { return dateFormatter.toString(doubleDate) }
        return dateFormatter.makeDateForUi(date: date)
    }
}
