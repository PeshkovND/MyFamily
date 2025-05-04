import Foundation
import AppServices
import Utilities
import AppEntities

final class FamilyRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    private func parseUsers(
        users: [UserPayload],
        statuses: [UserStatus],
        homePosition: Position
    ) -> [FamilyViewData] {
        guard let userId = authService.account?.id else { return [] }
        var result: [FamilyViewData] = []
        for user in users {
            guard
                user.id != userId,
                let status = statuses.first(where: { $0.userId == user.id }),
                let personStatus = makeStatus(lastOnlineDouble: status.lastOnline, position: status.position, homePosition: homePosition)
            else { continue }
            let userData = FamilyViewData(
                id: user.id,
                userImageURL: user.photoURL,
                name: user.firstName + " " + user.lastName,
                status: personStatus,
                isPro: user.pro
            )
            result.append(userData)
        }
        
        return result
    }
    
    func getUsers() async throws -> [FamilyViewData] {
        do {
            guard let familyId = authService.account?.familyId else { return [] }
            async let usersTask = firebaseClient.getAllUsers(familyId: familyId)
            async let statusesTask = firebaseClient.getAllUsersStatuses()
            async let positionTask = firebaseClient.getHomePosition(familyId: familyId)
            
            let usersResult = try await usersTask
            let statusesResult = try await statusesTask
            let positionResult = try await positionTask
            
            guard let users = try await firebaseClient.unwrapResult(
                result: usersResult,
                successAction: { users in try await swiftDataManager.setAllUsers(users: users) },
                failureAction: { try await swiftDataManager.getAllUsers(familyId: familyId) }
            ) else {
                return []
            }
            guard let statuses = try await firebaseClient.unwrapResult(
                result: statusesResult,
                successAction: { statusesPayload in
                    try await swiftDataManager.setAllStatuses(statuses: statusesPayload)
                },
                failureAction: { try await swiftDataManager.getAllStatuses() }
            ) else {
                return []
            }
            
            guard let homePosition = try await firebaseClient.unwrapResult(
                result: positionResult,
                successAction: { _ in },
                failureAction: { throw FirebaseClientError.fetchingError }
            ) else {
                throw FirebaseClientError.fetchingError
            }
            
            return parseUsers(users: users, statuses: statuses, homePosition: homePosition)
        } catch let e {
            throw e
        }
    }
    
    func getUserRole() -> Role {
        authService.account?.role ?? .regular
    }
    
    func deleteFamilyForUser(id: Int) async throws {
        let user = try await firebaseClient.getUser(id)
        switch user {
        case .success(let success):
            try await firebaseClient.updateUser(.init(
                id: success.id,
                photoURL: success.photoURL,
                firstName: success.firstName,
                lastName: success.lastName,
                familyId: nil,
                role: .regular
            ))
        case .failure(let failure):
            throw failure
        }
    }
    
    private func makeStatus(lastOnlineDouble: Double, position: Position, homePosition: Position) -> PersonStatus? {
        let dateFormatter = AppDateFormatter()
        guard let lastOnline = dateFormatter.toDate(lastOnlineDouble) else { return nil }
        var personStatus: PersonStatus = .online
        if Date().timeIntervalSince(lastOnline) > 300 {
            personStatus = .offline(lastOnline: dateFormatter.makeDateForUi(date: lastOnline))
        }
        if abs(position.lat - homePosition.lat) < 0.0001
            && abs(position.lng - homePosition.lng) < 0.0001 {
            personStatus = .atHome
        }
        return personStatus
    }
}
