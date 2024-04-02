import Foundation
import AppServices
import Utilities

final class MapRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    // swiftlint:disable function_body_length
    func getUsers() async throws -> [MapViewData] {
        guard let userId = authService.account?.id else { return [] }
        async let usersTask = firebaseClient.getAllUsers()
        async let statusesTask = firebaseClient.getAllUsersStatuses()
        
        let usersResult = try await usersTask
        let statusesResult = try await statusesTask
        var result: [MapViewData] = []
        
        var users: [UserPayload] = []
        switch usersResult {
        case .success(let usersPayload):
            users = usersPayload
            try await swiftDataManager.setAllUsers(users: users)
        case .failure(_):
            if let usersPayload = try await swiftDataManager.getAllUsers() {
                users = usersPayload
            }
        }
        
        var statuses: [UserStatus] = []
        switch statusesResult {
        case .success(let statusesPayload):
            statuses = statusesPayload
            try await swiftDataManager.setAllStatuses(statuses: statusesPayload)
        case .failure(_):
            if let statusesPayload = try await swiftDataManager.getAllStatuses() {
                statuses = statusesPayload
            }
        }
        
        for user in users {
            guard
                user.id != userId,
                let status = statuses.first(where: { $0.userId == user.id }),
                let personStatus = makeStatus(lastOnlineString: status.lastOnline, position: status.position)
            else { continue }
            let userData = MapViewData(
                id: user.id,
                userImageURL: user.photoURL,
                name: user.firstName + " " + user.lastName,
                status: personStatus,
                coordinate: Coordinate(latitude: status.position.lat, longitude: status.position.lng)
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
    
    func getHomePosition() -> Coordinate {
        let coordinates = firebaseClient.getHomePosition()
        return Coordinate(latitude: coordinates.lat, longitude: coordinates.lng)
    }
}
