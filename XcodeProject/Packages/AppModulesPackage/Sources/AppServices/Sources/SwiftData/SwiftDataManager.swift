//  

import Foundation
import SwiftData

public class SwiftDataManager {
    private let container: ModelContainer?
    private let context: ModelContext?
    
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
        let descriptor = FetchDescriptor<PostModel>()
        
        guard let postModels = try context?.fetch(descriptor) else { return nil }
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
    
    public func getPost(id: UUID) async throws -> PostPayload? {
        let predicate = #Predicate<PostModel> { $0.id == id }
        let descriptor = FetchDescriptor<PostModel>(predicate: predicate)
        
        guard let postModel = try context?.fetch(descriptor).first else { return nil }
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
    
    public func setAllPosts(posts: [PostPayload]) async throws {
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
    
    public func getAllComments() async throws -> [CommentPayload]? {
        let descriptor = FetchDescriptor<CommentModel>()
        
        guard let commentsModels = try context?.fetch(descriptor) else { return nil }
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
    
    public func getPostComments(id: UUID) async throws -> [CommentPayload]? {
        let predicate = #Predicate<CommentModel> { $0.postId == id }
        let descriptor = FetchDescriptor<CommentModel>(predicate: predicate)
        
        guard let commentsModels = try context?.fetch(descriptor) else { return nil }
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
    
    public func setAllComments(comments: [CommentPayload]) async throws {
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
    
    public func getAllUsers() async throws -> [UserPayload]? {
        let descriptor = FetchDescriptor<UserModel>()
        
        guard let models = try context?.fetch(descriptor) else { return nil }
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
    
    public func setAllUsers(users: [UserPayload]) async throws {
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
