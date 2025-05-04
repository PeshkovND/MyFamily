import Foundation
import AppServices
import Utilities
import AppEntities

final class MapRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getUsers(homePosition: Position) async throws -> [MapViewData] {
        do {
            guard let familyId = authService.account?.familyId else { return [] }
            async let usersTask = firebaseClient.getAllUsers(familyId: familyId)
            async let statusesTask = firebaseClient.getAllUsersStatuses()
            
            let usersResult = try await usersTask
            let statusesResult = try await statusesTask
            
            guard
                let users = try await firebaseClient.unwrapResult(
                    result: usersResult,
                    successAction: { payload in try await swiftDataManager.setAllUsers(users: payload) },
                    failureAction: { try await swiftDataManager.getAllUsers(familyId: familyId) }
                ),
                let statuses = try await firebaseClient.unwrapResult(
                    result: statusesResult,
                    successAction: { payload in try await swiftDataManager.setAllStatuses(statuses: payload) },
                    failureAction: { try await swiftDataManager.getAllStatuses() }
                )
            else { return [] }
            return parseData(users: users, statuses: statuses, homePosition: homePosition)
        } catch let e {
            throw e
        }
    }
    
    private func parseData(users: [UserPayload], statuses: [UserStatus], homePosition: Position) -> [MapViewData] {
        guard let userId = authService.account?.id else { return [] }
        var result: [MapViewData] = []
        
        for user in users {
            guard
                user.id != userId,
                let status = statuses.first(where: { $0.userId == user.id }),
                let personStatus = makeStatus(lastOnlineDouble: status.lastOnline, position: status.position, homePosition: homePosition)
            else { continue }
            let userData = MapViewData(
                id: user.id,
                userImageURL: user.photoURL,
                name: user.firstName + " " + user.lastName,
                status: personStatus,
                coordinate: Coordinate(latitude: status.position.lat, longitude: status.position.lng), isPro: user.pro
            )
            result.append(userData)
        }
        
        return result
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
    
    func getHomePosition() async throws -> Coordinate {
        guard let familyId = authService.account?.familyId else { throw AppError.unathorized }
        let coordinates = try await firebaseClient.getHomePosition(familyId: familyId)
        switch coordinates {
        case .success(let success):
            return Coordinate(latitude: success.lat, longitude: success.lng)
        case .failure(let failure):
            throw failure
        }
    }
    
    func observeAllUsersStatuses(usersIds: [Int], onDataChange: @escaping (UserStatus) -> Void) {
        firebaseClient.observeAllUsersStatuses(usersIds: usersIds, onDataChange: onDataChange)
    }
}
