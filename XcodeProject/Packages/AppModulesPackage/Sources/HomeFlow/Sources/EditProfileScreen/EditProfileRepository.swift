import Foundation
import AppServices
import Utilities

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
    
    func getUserInfo() -> UserInfo? {
        return authService.account
    }
}
