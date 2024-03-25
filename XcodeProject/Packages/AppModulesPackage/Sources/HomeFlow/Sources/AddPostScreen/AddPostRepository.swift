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
    
    func uploadImage(image: Data) async throws -> URL {
        return try await firebaseClient.uploadImage(image: image)
    }
    
    func uploadVideo(video: Data) async throws -> URL {
        return try await firebaseClient.uploadVideo(video: video)
    }
    
    func uploadAudio(url: URL) async throws -> URL {
        return try await firebaseClient.uploadAudio(url: url)
    }
    
    func addPost(text: String?, contentURL: URL?, contentType: ContentType?) async throws {
        guard let userId = authService.account?.id else { return }
        let dateFormatter = AppDateFormatter()
        let date = dateFormatter.toString(Date())
        let post = PostPayload(
            id: UUID(),
            text: text,
            contentURL: contentURL,
            contentType: contentType,
            userId: userId,
            date: date,
            likes: []
        )
        try await firebaseClient.addPost(post)
    }
}
