import Foundation
import AppServices
import Utilities
import AppEntities

final class EditProfileRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func uploadImage(image: Data) async throws -> URL {
        return try await firebaseClient.uploadImage(image: image)
    }
    
    func getUserInfo() -> Account? {
        return authService.account
    }
    
    func editUser(name: String, surname: String, imageURL: URL) async throws {
        guard let currentUserInfo = authService.account else { return }
        
        let userInfo = UserInfo(
            id: currentUserInfo.id,
            photoURL: imageURL,
            firstName: name,
            lastName: surname
        )
        
        try await self.firebaseClient.updateUser(userInfo)
        authService.updateAccount(userInfo)
    }
}
