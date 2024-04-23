//

import Foundation
import AppServices
import Utilities
import AppEntities

final class PostRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getPostData(id: UUID) async throws -> (NewsViewPost?, [Comment]) {
        do {
            async let postTask = firebaseClient.getPost(id)
            async let commentsTask = firebaseClient.getCommentsOnPost(id)
            async let usersTask = firebaseClient.getAllUsers()
            
            let postResult = try await postTask
            let commentsResult = try await commentsTask
            let usersResult = try await usersTask
            
            guard
                let users = try await firebaseClient.unwrapResult(
                    result: usersResult,
                    successAction: { payload in try await swiftDataManager.setAllUsers(users: payload) },
                    failureAction: { try await swiftDataManager.getAllUsers() }
                ),
                let post = try await firebaseClient.unwrapResult(
                    result: postResult,
                    successAction: { payload in try await swiftDataManager.setAllPosts(posts: [payload]) },
                    failureAction: { try await swiftDataManager.getPost(id: id) }
                ),
                let comments = try await firebaseClient.unwrapResult(
                    result: commentsResult,
                    successAction: { payload in try await swiftDataManager.setAllComments(comments: payload) },
                    failureAction: { try await swiftDataManager.getPostComments(id: id) }
                )
            else { return (nil, []) }
            
            let newsPost = makePost(post: post, comments: comments, users: users)
            let newsComments = makeComments(comments: comments, users: users)
            return (newsPost, newsComments)
        } catch let e {
            throw e
        }
    }
    
    private func makePost(post: PostPayload, comments: [CommentPayload], users: [UserPayload]) -> NewsViewPost? {
        guard let userId = authService.account?.id else { return nil }
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
        
        guard let user = users.first(where: { elem in elem.id == post.userId }) else { return nil }
        
        return NewsViewPost(
            id: post.id.uuidString,
            userId: post.userId,
            userImageURL: user.photoURL,
            name: user.firstName + " " + user.lastName,
            contentLabel: post.text,
            mediaContent: mediaContent,
            likesCount: post.likes.count,
            commentsCount: commentCount,
            isLiked: isLiked,
            isPremium: user.pro
        )
    }
    
    private func makeComments(comments: [CommentPayload], users: [UserPayload]) -> [Comment] {
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
        return newsComments
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
        case .failure:
            return
        }
    }
    
    public func addComment(text: String, postId: UUID) async throws -> Comment? {
        do {
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
        } catch let e {
            throw e
        }
    }
}
