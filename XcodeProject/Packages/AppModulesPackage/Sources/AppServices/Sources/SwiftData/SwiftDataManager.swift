//  

import Foundation
import SwiftData

public class SwiftDataMAnager {
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
}
