//

import Foundation
import AppServices
import Utilities

final class PostRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    
    init(firebaseClient: FirebaseClient, authService: AuthService) {
        self.firebaseClient = firebaseClient
        self.authService = authService
    }
    
    // swiftlint:disable function_body_length
    func getPostData(id: UUID) async throws -> (NewsViewPost?, [Comment]) {
        guard let userId = authService.account?.id else { return (nil, []) }
        async let postTask = firebaseClient.getPost(id)
        async let commentsTask = firebaseClient.getCommentsOnPost(id)
        async let usersTask = firebaseClient.getAllUsers()
        
        let post = try await postTask
        let comments = try await commentsTask
        let users = try await usersTask
        
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
        
        guard let user = users.first(where: { elem in
            elem.id == post.userId
        }) else { return (nil, []) }
        
        let newsPost = NewsViewPost(
            id: post.id.uuidString,
            userId: post.userId,
            userImageURL: user.photoURL,
            name: user.firstName + " " + user.lastName,
            contentLabel: post.text,
            mediaContent: mediaContent,
            likesCount: post.likes.count,
            commentsCount: commentCount,
            isLiked: isLiked
        )
            
        var newsComments: [Comment] = []
        for comment in comments {
            guard let user = users.first(where: { elem in
                elem.id == post.userId
            }) else { continue }
        
            let newsComment = Comment(
                userId: user.id,
                username: user.firstName + " " + user.lastName,
                imageUrl: user.photoURL,
                text: comment.text
            )
            newsComments.append(newsComment)
        }
        return (newsPost, newsComments)
    }
    
    public func likeOrUnlikePost(postId: UUID) async throws {
        guard let userId = authService.account?.id else { return }
        var post = try await firebaseClient.getPost(postId)
        if let index = post.likes.firstIndex(where: { elem in elem == userId }) {
            post.likes.remove(at: index)
        } else {
            post.likes.append(userId)
            
        }
        try await self.firebaseClient.addPost(post)
    }
    
    public func addComment(text: String, postId: UUID) async throws -> Comment? {
        guard let user = authService.account else { return nil }
        let dateFormatter = AppDateFormatter()
        let dateString = dateFormatter.toString(Date())
        let commentPayload = CommentPayload(
            id: UUID(),
            userId: user.id,
            postId: postId,
            text: text,
            date: dateString
        )
        try await firebaseClient.addComment(commentPayload)
    
        return Comment(
            userId: user.id,
            username: user.firstName + " " + user.lastName,
            imageUrl: user.photoURL,
            text: text
        )
    }
}
