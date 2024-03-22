import Foundation
import AppServices
import Utilities

final class AddPostRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    func uploadImage(image: Data) async throws {
        let url = try await firebaseClient.uploadImage(image: image)
        print(url)
    }
    
    func uploadVideo(video: Data) async throws {
        let url = try await firebaseClient.uploadVideo(video: video)
        print(url)
    }
}
