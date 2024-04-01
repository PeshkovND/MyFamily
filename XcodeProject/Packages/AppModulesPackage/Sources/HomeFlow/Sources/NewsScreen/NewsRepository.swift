//  

import Foundation
import AppServices

final class NewsRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataMAnager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataMAnager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    // swiftlint:disable function_body_length
    func getPosts() async throws -> [NewsViewPost] {
        guard let userId = authService.account?.id else { return [] }
        async let postsTask = firebaseClient.getAllPosts()
        async let commentsTask = firebaseClient.getAllComments()
        async let usersTask = firebaseClient.getAllUsers()
        
        let postsResult = try await postsTask
        let commentsResult = try await commentsTask
        let users = try await usersTask
        
        var comments: [CommentPayload] = []
        switch commentsResult {
        case .success(let commentsPayload):
            comments = commentsPayload
            try await swiftDataManager.setAllComments(comments: commentsPayload)
        case .failure(_):
            if let commentsPayload = try await swiftDataManager.getAllComments() {
                comments = commentsPayload
            }
        }
        
        var result: [NewsViewPost] = []
            
        switch postsResult {
        case .success(let posts):
            result = parsePosts(posts: posts, users: users, comments: comments)
            try await self.swiftDataManager.setAllPosts(posts: posts)
        case .failure(_):
            guard let posts = try await self.swiftDataManager.getAllPosts() else { return [] }
            result = parsePosts(posts: posts, users: users, comments: comments)
        }
        
        return result
    }
    
    private func parsePosts(posts: [PostPayload], users: [UserPayload], comments: [CommentPayload]) -> [NewsViewPost] {
        guard let userId = authService.account?.id else { return [] }
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
                userId: post.userId,
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
}
