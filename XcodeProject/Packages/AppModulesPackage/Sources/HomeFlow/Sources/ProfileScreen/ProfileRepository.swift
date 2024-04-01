//

import Foundation
import AppServices
import Utilities

final class ProfileRepository {
    private let firebaseClient: FirebaseClient
    private let authService: AuthService
    private let swiftDataManager: SwiftDataMAnager
    
    init(firebaseClient: FirebaseClient, authService: AuthService, swiftDataManager: SwiftDataMAnager) {
        self.firebaseClient = firebaseClient
        self.authService = authService
        self.swiftDataManager = swiftDataManager
    }
    
    func getProfile(id: Int) async throws -> Profile? {
        guard let userId = authService.account?.id else { return nil }
        async let postsTask = firebaseClient.getUsersPosts(userId: id)
        async let commentsTask = firebaseClient.getAllComments()
        async let userTask = firebaseClient.getUser(id)
        async let statusTask = firebaseClient.getUserStatus(id)
        
        let posts = try await postsTask
        let commentsResult = try await commentsTask
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
        
        guard let user = try await userTask else { return nil }
        let status = try await statusTask
        let username = user.firstName + " " + user.lastName
        
        guard let personStatus = makeStatus(
            lastOnlineString: status.lastOnline,
            position: status.position
        ) else { return nil }
        let newsPosts = makePosts(posts: posts, comments: comments, currentUserId: userId, user: user)
          
        let profile = Profile(
            id: id,
            userImageURL: user.photoURL,
            name: username,
            status: personStatus,
            posts: newsPosts
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
                isLiked: isLiked
            )
            
            newsPosts.append(newsPost)
        }
        return newsPosts
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
    
    public func isCurrentUser(id: Int) -> Bool {
        self.authService.account?.id == id
    }
}
