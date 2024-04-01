//

import Foundation
import AppServices
import Utilities

final class PostRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func getPostData(id: UUID) async throws -> (NewsViewPost?, [Comment]) {
        guard let userId = authService.account?.id else { return (nil, []) }
        async let postTask = firebaseClient.getPost(id)
        async let commentsTask = firebaseClient.getCommentsOnPost(id)
        async let usersTask = firebaseClient.getAllUsers()
        
        let postResult = try await postTask
        let commentsResult = try await commentsTask
        let usersResult = try await usersTask
        
        var users: [UserPayload] = []
        switch usersResult {
        case .success(let usersPayload):
            users = usersPayload
            try await swiftDataManager.setAllUsers(users: usersPayload)
        case .failure:
            if let usersPayload = try await swiftDataManager.getAllUsers() {
                users = usersPayload
            }
        }
        
        var post: PostPayload? = nil
        switch postResult {
        case .success(let postPayload):
            post = postPayload
            try await swiftDataManager.setAllPosts(posts: [postPayload])
        case .failure:
            if let postPayload = try await swiftDataManager.getPost(id: id) {
                post = postPayload
            }
        }
        
        var comments: [CommentPayload] = []
        switch commentsResult {
        case .success(let commentsPayload):
            comments = commentsPayload
            try await swiftDataManager.setAllComments(comments: comments)
        case .failure:
            if let commentsPayload = try await swiftDataManager.getPostComments(id: id) {
                comments = commentsPayload
            }
        }
        
        guard let post = post else { return (nil, []) }
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
                elem.id == comment.userId
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
        let postResult = try await firebaseClient.getPost(postId)
        switch postResult {
        case .success(var post):
            if let index = post.likes.firstIndex(where: { elem in elem == userId }) {
                post.likes.remove(at: index)
            } else {
                post.likes.append(userId)
                
            }
            try await self.firebaseClient.addPost(post)
        case .failure(_):
            return
        }
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
