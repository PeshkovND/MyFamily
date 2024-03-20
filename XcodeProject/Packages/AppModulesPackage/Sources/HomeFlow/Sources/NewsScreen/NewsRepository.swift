//  

import Foundation
import AppServices

final class NewsRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    // swiftlint:disable function_body_length
    func getPosts() async throws -> [NewsViewPost] {
        guard let userId = authService.account?.id else { return [] }
        async let postsTask = firebaseClient.getAllPosts()
        async let commentsTask = firebaseClient.getAllComments()
        async let usersTask = firebaseClient.getAllUsers()
        
        let posts = try await postsTask
        let comments = try await commentsTask
        let users = try await usersTask
        
        var result: [NewsViewPost] = []
            
        for post in posts {
            guard let user = users.first(where: { elem in
                elem.id == post.userId
            }) else { continue }
            let commentCount = comments.filter { elem in
                elem.postId == post.id
            }.count
            let isLiked = post.likes.contains(userId)
            
            var mediaContent: MediaContent?
            
            switch post.contentType {
            case .audio:
                mediaContent = .Audio(url: post.contentURL)
            case .none:
                mediaContent = nil
            case .video:
                mediaContent = .Video(url: post.contentURL)
            case .image:
                mediaContent = .Image(url: post.contentURL)
            }
            
            let newsPost = NewsViewPost(
                id: post.id.uuidString,
                userId: String(post.userId),
                userImageURL: user.photoURL,
                name: user.firstName + " " + user.lastName,
                contentLabel: post.text,
                mediaContent: mediaContent,
                likesCount: post.likes.count,
                commentsCount: commentCount,
                isLiked: isLiked
            )
            
            result.append(newsPost)
        }
        return result
    }
}
