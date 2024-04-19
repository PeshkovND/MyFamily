//  

import Foundation
import SwiftData
import AppEntities

@Model
public class CommentModel {
    @Attribute(.unique) public let id: UUID
    public let userId: Int
    public let postId: UUID
    public let text: String
    public let date: String
    
    public init(id: UUID, userId: Int, postId: UUID, text: String, date: String) {
        self.id = id
        self.userId = userId
        self.postId = postId
        self.text = text
        self.date = date
    }
}

@Model
public class UserStatusModel {
    @Attribute(.unique) public let userId: Int
    public let lastOnline: String
    public let position: Position
    
    public init(userId: Int, lastOnline: String, position: Position) {
        self.userId = userId
        self.lastOnline = lastOnline
        self.position = position
    }
}

@Model
public class UserModel {
    @Attribute(.unique) public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    public let role: Role
    public var pro: Bool
    
    init(id: Int, photoURL: URL?, firstName: String, lastName: String, role: Role, pro: Bool) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.pro = pro
    }
}

@Model
public class PostModel {
    @Attribute(.unique) public let id: UUID
    public let text: String?
    public let contentURL: URL?
    public let contentType: ContentType?
    public let userId: Int
    public let date: String
    public var likes: [Int]
    
    public init(id: UUID, text: String?, contentURL: URL?, contentType: ContentType?, userId: Int, date: String, likes: [Int]) {
        self.id = id
        self.text = text
        self.contentURL = contentURL
        self.contentType = contentType
        self.userId = userId
        self.date = date
        self.likes = likes
    }
}
