//  

import Foundation
import AppServices

final class NewsRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getPosts() async throws -> [NewsViewPost] {
        do {
            async let postsTask = firebaseClient.getAllPosts()
            async let commentsTask = firebaseClient.getAllComments()
            async let usersTask = firebaseClient.getAllUsers()
            
            let postsResult = try await postsTask
            let commentsResult = try await commentsTask
            let usersResult = try await usersTask
            
            guard
                let comments = try await firebaseClient.unwrapResult(
                    result: commentsResult,
                    successAction: { payload in try await swiftDataManager.setAllComments(comments: payload) },
                    failureAction: { try await swiftDataManager.getAllComments() }
                ),
                let users = try await firebaseClient.unwrapResult(
                    result: usersResult,
                    successAction: { payload in try await swiftDataManager.setAllUsers(users: payload) },
                    failureAction: { try await swiftDataManager.getAllUsers() }
                ),
                let posts = try await firebaseClient.unwrapResult(
                    result: postsResult,
                    successAction: { payload in try await self.swiftDataManager.setAllPosts(posts: payload) },
                    failureAction: { try await self.swiftDataManager.getAllPosts() }
                )
            else { return [] }
            
            return parsePosts(posts: posts, users: users, comments: comments)
        } catch let e {
            throw e
        }
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
}
