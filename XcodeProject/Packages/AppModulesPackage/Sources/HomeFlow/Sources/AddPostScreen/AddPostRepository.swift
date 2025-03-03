import Foundation
import AppServices
import Utilities
import AppEntities

final class AddPostRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let textToxicityChecker: TextToxicityChecker
    
    init(firebaseClient: FirebaseClient, authService: AuthService, textToxicityChecker: TextToxicityChecker) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.textToxicityChecker = textToxicityChecker
    }
    
    func uploadMedia(data: Data, contentType: ContentType) async throws -> URL {
        switch contentType {
        case .audio:
            return try await firebaseClient.uploadAudio(audio: data)
        case .image:
            return try await firebaseClient.uploadImage(image: data)
        case .video:
            return try await firebaseClient.uploadVideo(video: data)
        }
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
    
    func checkTextToxicity(
        inputText: String,
        onSuccess: @escaping (Bool) -> Void,
        onFailure: @escaping () -> Void
    ) {
        textToxicityChecker.checkToxicity(
            inputText: inputText,
            onSuccess: onSuccess,
            onFailure: onFailure
        )
    }
}
