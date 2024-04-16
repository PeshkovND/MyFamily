//

import Foundation
import AppServices
import Utilities

final class ProfileRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataManager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataManager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getProfile(id: Int) async throws -> Profile? {
        do {
            async let postsTask = firebaseClient.getUsersPosts(userId: id)
            async let commentsTask = firebaseClient.getAllComments()
            async let userTask = firebaseClient.getUser(id)
            async let statusTask = firebaseClient.getUserStatus(id)
            
            let postsResult = try await postsTask
            let commentsResult = try await commentsTask
            let userResult = try await userTask
            let statusResult = try await statusTask
            
            guard
                let posts = try await firebaseClient.unwrapResult(
                    result: postsResult,
                    successAction: { payload in try await self.swiftDataManager.setAllPosts(posts: payload) },
                    failureAction: { try await self.swiftDataManager.getUserPosts(id: id) }
                ),
                let comments = try await firebaseClient.unwrapResult(
                    result: commentsResult,
                    successAction: { payload in try await swiftDataManager.setAllComments(comments: payload) },
                    failureAction: { try await swiftDataManager.getAllComments() }
                ),
                let user = try await firebaseClient.unwrapResult(
                    result: userResult,
                    successAction: { payload in try await self.swiftDataManager.setAllUsers(users: [payload]) },
                    failureAction: { try await swiftDataManager.getUser(id: id) }
                ),
                let status = try await firebaseClient.unwrapResult(
                    result: statusResult,
                    successAction: { payload in try await self.swiftDataManager.setAllStatuses(statuses: [payload]) },
                    failureAction: { try await swiftDataManager.getUserStatus(id: id) }
                ) else { return nil }
            
            return makeProfile(
                id: id,
                user: user,
                status: status,
                posts: posts,
                comments: comments
            )
        } catch let e {
            throw e
        }
    }
    
    private func makeProfile(
        id: Int,
        user: UserPayload,
        status: UserStatus,
        posts: [PostPayload],
        comments: [CommentPayload]
    ) -> Profile? {
        guard let userId = authService.account?.id,
              let personStatus = makeStatus(
                lastOnlineString: status.lastOnline,
                position: status.position
              ) else { return nil }
        let newsPosts = makePosts(posts: posts, comments: comments, currentUserId: userId, user: user)
        let profile = Profile(
            id: id,
            userImageURL: user.photoURL,
            name: user.firstName + " " + user.lastName,
            status: personStatus,
            posts: newsPosts,
            isPremium: user.pro
        )
        
        return profile
    }
    
    private func makeStatus(lastOnlineString: String, position: Position) -> PersonStatus? {
        let dateFormatter = AppDateFormatter()
        guard let lastOnline = dateFormatter.toDate(lastOnlineString) else { return nil }
        var personStatus: PersonStatus = .online
        if Date().timeIntervalSince(lastOnline) > 300 {
            personStatus = .offline(lastOnline: lastOnlineString)
        }
        let homePosition = firebaseClient.getHomePosition()
        if abs(position.lat - homePosition.lat) < 0.0001
            && abs(position.lng - homePosition.lng) < 0.0001 {
            personStatus = .atHome
        }
        return personStatus
    }
    
    private func makePosts(
        posts: [PostPayload],
        comments: [CommentPayload],
        currentUserId: Int,
        user: UserPayload
    ) -> [NewsViewPost] {
        var newsPosts: [NewsViewPost] = []
        
        for post in posts {
            let commentCount = comments.filter { elem in
                elem.postId == post.id
            }.count
            let isLiked = post.likes.contains(currentUserId)
            
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
                isLiked: isLiked,
                isPremium: user.pro
            )
            
            newsPosts.append(newsPost)
        }
        return newsPosts
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
    
    public func isCurrentUser(id: Int) -> Bool {
        self.authService.account?.id == id
    }
}
