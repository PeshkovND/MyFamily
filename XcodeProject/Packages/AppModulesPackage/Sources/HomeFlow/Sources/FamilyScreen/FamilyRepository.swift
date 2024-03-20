import Foundation
import AppServices
import Utilities

final class FamilyRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func getUsers() async throws -> [FamilyViewData] {
        guard let userId = authService.account?.id else { return [] }
        async let usersTask = firebaseClient.getAllUsers(instead: userId)
        async let statusesTask = firebaseClient.getAllUsersStatuses()
        
        let users = try await usersTask
        let statuses = try await statusesTask
        var result: [FamilyViewData] = []
        for user in users {
            guard
                let status = statuses.first(where: { $0.userId == user.id }),
                let personStatus = makeStatus(lastOnlineString: status.lastOnline, position: status.position)
            else { continue }
            let userData = FamilyViewData(
                id: user.id,
                userImageURL: user.photoURL,
                name: user.firstName + " " + user.lastName,
                status: personStatus
            )
            result.append(userData)
        }
        
        return result
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
