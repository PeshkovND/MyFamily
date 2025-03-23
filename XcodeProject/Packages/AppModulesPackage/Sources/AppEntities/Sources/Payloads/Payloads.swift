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
    
    public func dictionary() -> [String: Any] {
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
    
    public func dictionary() -> [String: Any] {
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
    public let familyId: String?
    public let role: Role
    
    public init(id: Int, photoURL: URL?, firstName: String, lastName: String, familyId: String?, role: Role) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
        self.familyId = familyId
        self.role = role
    }
}

public struct UserPayload: Codable {
    public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    public let role: Role
    public var pro: Bool
    public var familyId: String?
    
    public init(id: Int, photoURL: URL?, firstName: String, lastName: String, role: Role, pro: Bool, familyId: String?) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.pro = pro
        self.familyId = familyId
    }
    
    public func dictionary() -> [String: Any] {
        return [
            "id": id,
            "photoURL": photoURL?.absoluteString as Any,
            "firstName": firstName,
            "lastName": lastName,
            "role": role.rawValue,
            "pro": pro,
            "familyId": familyId as Any
        ]
    }

}

public struct InvitePayload: Codable {
    public let id: String
    public let dateCreated: String
    public let familyId: String
    
    public init(id: String, dateCreated: String, familyId: String) {
        self.id = id
        self.dateCreated = dateCreated
        self.familyId = familyId
    }
    
    public func dictionary() -> [String: Any] {
        return [
            "id": id,
            "dateCreated": dateCreated,
            "familyId": familyId
        ]
    }

}

public struct FamilyPayload: Codable {
    public let id: UUID
    public let name: String
    public let homeLongitude: Double
    public let homeLatitude: Double
    
    public init(id: UUID, name: String, homeLongitude: Double, homeLatitude: Double) {
        self.id = id
        self.name = name
        self.homeLatitude = homeLatitude
        self.homeLongitude = homeLongitude
    }
    
    public func dictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "homeLatitude": homeLatitude,
            "homeLongitude": homeLongitude
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
    
    public func dictionary() -> [String: Any] {
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
