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
        statuses: [UserStatus]
    ) -> [FamilyViewData] {
        guard let userId = authService.account?.id else { return [] }
        var result: [FamilyViewData] = []
        for user in users {
            guard
                user.id != userId,
                let status = statuses.first(where: { $0.userId == user.id }),
                let personStatus = makeStatus(lastOnlineString: status.lastOnline, position: status.position)
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
            async let usersTask = firebaseClient.getAllUsers()
            async let statusesTask = firebaseClient.getAllUsersStatuses()
            
            let usersResult = try await usersTask
            let statusesResult = try await statusesTask
            
            guard let users = try await firebaseClient.unwrapResult(
                result: usersResult,
                successAction: { users in try await swiftDataManager.setAllUsers(users: users) },
                failureAction: { try await swiftDataManager.getAllUsers() }
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
            
            return parseUsers(users: users, statuses: statuses)
        } catch let e {
            throw e
        }
    }
    
    private func makeStatus(lastOnlineString: String, position: Position) -> PersonStatus? {
        let dateFormatter = AppDateFormatter()
        guard let lastOnline = dateFormatter.toDate(lastOnlineString) else { return nil }
        var personStatus: PersonStatus = .online
        if Date().timeIntervalSince(lastOnline) > 300 {
            personStatus = .offline(lastOnline: lastOnlineString)
        }
        let homePosition = firebaseClient.getHomePosition()
        if abs(position.lat - homePosition.lat) < 0.0001
            && abs(position.lng - homePosition.lng) < 0.0001 {
            personStatus = .atHome
        }
        return personStatus
    }
}
