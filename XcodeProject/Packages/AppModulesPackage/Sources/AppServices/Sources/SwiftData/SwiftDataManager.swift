//  

import Foundation
import SwiftData

public enum SwiftDataManagerError: Error {
    case dataNotFound
}

public class SwiftDataManager {
    private let container: ModelContainer?
    private let context: ModelContext?
    private let queue = DispatchQueue(label: "swift-data")
    
    public init() {
        container = try? ModelContainer(
            for: CommentModel.self, UserStatusModel.self, UserModel.self, PostModel.self
        )
        guard let container = container else {
            context = nil
            return
        }
        context = ModelContext(container)
    }
    
    public func getAllPosts() async throws -> [PostPayload]? {
        try queue.sync {
            let descriptor = FetchDescriptor<PostModel>()
            
            guard
                let postModels = try context?.fetch(descriptor),
                !postModels.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return postModels.sorted(by: { $0.date > $1.date }).map { elem in
                PostPayload(
                    id: elem.id,
                    text: elem.text,
                    contentURL: elem.contentURL,
                    contentType: elem.contentType,
                    userId: elem.userId,
                    date: elem.date,
                    likes: elem.likes
                )
            }
        }
    }
    
    public func getPost(id: UUID) async throws -> PostPayload? {
        try queue.sync {
            let predicate = #Predicate<PostModel> { $0.id == id }
            let descriptor = FetchDescriptor<PostModel>(predicate: predicate)
            
            guard let postModel = try context?.fetch(descriptor).first else { throw SwiftDataManagerError.dataNotFound }
            return PostPayload(
                id: postModel.id,
                text: postModel.text,
                contentURL: postModel.contentURL,
                contentType: postModel.contentType,
                userId: postModel.userId,
                date: postModel.date,
                likes: postModel.likes
            )
        }
    }
    
    public func getUserPosts(id: Int) async throws -> [PostPayload]? {
        try queue.sync {
            let predicate = #Predicate<PostModel> { $0.userId == id }
            let descriptor = FetchDescriptor<PostModel>(predicate: predicate)
            
            guard
                let postModels = try context?.fetch(descriptor),
                !postModels.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return postModels.map { elem in
                PostPayload(
                    id: elem.id,
                    text: elem.text,
                    contentURL: elem.contentURL,
                    contentType: elem.contentType,
                    userId: elem.userId,
                    date: elem.date,
                    likes: elem.likes
                )
            }
        }
    }
    
    public func setAllPosts(posts: [PostPayload]) async throws {
        try queue.sync {
            posts.forEach { elem in
                let postModel = PostModel(
                    id: elem.id,
                    text: elem.text,
                    contentURL: elem.contentURL,
                    contentType: elem.contentType,
                    userId: elem.userId,
                    date: elem.date,
                    likes: elem.likes
                )
                context?.insert(postModel)
            }
            
            try context?.save()
        }
    }
    
    public func getAllComments() async throws -> [CommentPayload]? {
        try queue.sync {
            let descriptor = FetchDescriptor<CommentModel>()
            
            guard
                let commentsModels = try context?.fetch(descriptor),
                !commentsModels.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return commentsModels.map { elem in
                CommentPayload(
                    id: elem.id,
                    userId: elem.userId,
                    postId: elem.postId,
                    text: elem.text,
                    date: elem.date
                )
            }
        }
    }
    
    public func getPostComments(id: UUID) async throws -> [CommentPayload]? {
        try queue.sync {
            let predicate = #Predicate<CommentModel> { $0.postId == id }
            let descriptor = FetchDescriptor<CommentModel>(predicate: predicate)
            
            guard
                let commentsModels = try context?.fetch(descriptor),
                !commentsModels.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return commentsModels.map { elem in
                CommentPayload(
                    id: elem.id,
                    userId: elem.userId,
                    postId: elem.postId,
                    text: elem.text,
                    date: elem.date
                )
            }
        }
    }
    
    public func setAllComments(comments: [CommentPayload]) async throws {
        try queue.sync {
            comments.forEach { elem in
                let commentModel = CommentModel(
                    id: elem.id,
                    userId: elem.userId,
                    postId: elem.postId,
                    text: elem.text,
                    date: elem.date
                )
                context?.insert(commentModel)
            }
            
            try context?.save()
        }
    }
    
    public func getAllUsers() async throws -> [UserPayload]? {
        try queue.sync {
            let descriptor = FetchDescriptor<UserModel>()
            
            guard
                let models = try context?.fetch(descriptor),
                !models.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return models.map { elem in
                UserPayload(
                    id: elem.id,
                    photoURL: elem.photoURL,
                    firstName: elem.firstName,
                    lastName: elem.lastName,
                    role: elem.role,
                    pro: elem.pro
                )
            }
        }
    }
    
    public func getUser(id: Int) async throws -> UserPayload? {
        try queue.sync {
            let predicate = #Predicate<UserModel> { $0.id == id }
            let descriptor = FetchDescriptor<UserModel>(predicate: predicate)
            
            guard let model = try context?.fetch(descriptor).first else { throw SwiftDataManagerError.dataNotFound }
            return UserPayload(
                id: model.id,
                photoURL: model.photoURL,
                firstName: model.firstName,
                lastName: model.lastName,
                role: model.role,
                pro: model.pro
            )
        }
    }
    
    public func setAllUsers(users: [UserPayload]) async throws {
        try queue.sync {
            users.forEach { elem in
                let model = UserModel(
                    id: elem.id,
                    photoURL: elem.photoURL,
                    firstName: elem.firstName,
                    lastName: elem.lastName,
                    role: elem.role,
                    pro: elem.pro
                )
                context?.insert(model)
            }
            
            try context?.save()
        }
    }
    
    public func setAllStatuses(statuses: [UserStatus]) async throws {
        try queue.sync {
            statuses.forEach { elem in
                let model = UserStatusModel(
                    userId: elem.userId,
                    lastOnline: elem.lastOnline,
                    position: elem.position
                )
                context?.insert(model)
            }
            
            try context?.save()
        }
    }
    
    public func getAllStatuses() async throws -> [UserStatus]? {
        try queue.sync {
            let descriptor = FetchDescriptor<UserStatusModel>()
            
            guard
                let models = try context?.fetch(descriptor),
                !models.isEmpty
            else { throw SwiftDataManagerError.dataNotFound }
            return models.map { elem in
                UserStatus(
                    userId: elem.userId,
                    lastOnline: elem.lastOnline,
                    position: elem.position
                )
            }
        }
    }
    
    public func getUserStatus(id: Int) async throws -> UserStatus? {
        try queue.sync {
            let predicate = #Predicate<UserStatusModel> { $0.userId == id }
            let descriptor = FetchDescriptor<UserStatusModel>(predicate: predicate)
            
            guard let model = try context?.fetch(descriptor).first else { throw SwiftDataManagerError.dataNotFound }
            return UserStatus(
                userId: model.userId,
                lastOnline: model.lastOnline,
                position: model.position
            )
            
        }
    }
}
