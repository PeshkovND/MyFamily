//  

import Foundation

public enum Role: String, Codable {
    case owner
    case regular
}

public enum ContentType: String, Codable {
    case video
    case image
    case audio
}

public struct Position: Codable {
    public let lat: Double
    public let lng: Double
    
    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    func dictionary() -> [String: Any] {
        return [
            "lat": lat,
            "lng": lng
        ]
    }
}

public struct CommentPayload: Codable {
    public let id: UUID
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
    
    func dictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "postId": postId.uuidString,
            "text": text,
            "date": date
        ]
    }
}

public struct UserStatus: Codable {
    public let userId: Int
    public let lastOnline: String
    public var position: Position
    
    public init(userId: Int, lastOnline: String, position: Position) {
        self.userId = userId
        self.lastOnline = lastOnline
        self.position = position
    }
    
    func dictionary() -> [String: Any] {
        return [
            "userId": userId,
            "lastOnline": lastOnline,
            "position": position.dictionary()
        ]
    }
}

public struct UserInfo: Codable {
    public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    
    public init(id: Int, photoURL: URL?, firstName: String, lastName: String) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
    }
}

public struct UserPayload: Codable {
    public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    public let role: Role
    public var pro: Bool
    
    func dictionary() -> [String: Any] {
        return [
            "id": id,
            "photoURL": photoURL?.absoluteString as Any,
            "firstName": firstName,
            "lastName": lastName,
            "role": role.rawValue,
            "pro": pro
        ]
    }

}

public struct PostPayload: Codable {
    public let id: UUID
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
    
    func dictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "text": text as Any,
            "contentURL": contentURL?.absoluteString as Any,
            "contentType": contentType?.rawValue as Any,
            "userId": userId,
            "date": date,
            "likes": likes
        ]
    }
}
