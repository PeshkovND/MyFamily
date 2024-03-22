import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

private final class Collections {
    static let posts = "Posts"
    static let users = "Users"
    static let comments = "Comments"
    static let statuses = "Statuses"
}

enum ParsingError: Error {
    case error
}

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
    public let position: Position
    
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

public class FirebaseClient {

    lazy var fs = Firestore.firestore()
    lazy var db = Database.database().reference()
    lazy var storage = Storage.storage().reference()
    
    public init() {}
    
    public func addUser(_ user: UserInfo) async throws {
        let document = try await fs.collection(Collections.users).document(String(user.id)).getDocument()
        guard !document.exists else { return }
        let user = UserPayload(
            id: user.id,
            photoURL: user.photoURL,
            firstName: user.firstName,
            lastName: user.lastName,
            role: .regular,
            pro: false
        )
        try await self.fs.collection(Collections.users).document(String(user.id)).setData(user.dictionary())
    }
    
    public func getUser(_ id: Int) async throws -> UserPayload {
        try await fs.collection(Collections.users).document(String(id)).getDocument(as: UserPayload.self)
    }
    
    public func getAllUsers(instead id: Int) async throws -> [UserPayload] {
        let snapshot = try await fs.collection(Collections.users).getDocuments()
        var result: [UserPayload] = []
        for doc in snapshot.documents {
            do {
                let user = try doc.data(as: UserPayload.self)
                guard user.id != id else { continue }
                result.append(user)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func getAllUsers() async throws -> [UserPayload] {
        let snapshot = try await fs.collection(Collections.users).getDocuments()
        var result: [UserPayload] = []
        for doc in snapshot.documents {
            do {
                let user = try doc.data(as: UserPayload.self)
                result.append(user)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func addComment(_ comment: CommentPayload) async throws {
        try await self.fs.collection(Collections.comments)
            .document(comment.id.uuidString)
            .setData(comment.dictionary())
    }
    
    public func getCommentsOnPost(_ id: UUID) async throws -> [CommentPayload] {
        let collection = fs.collection(Collections.comments)
        let query = collection.whereField("postId", isEqualTo: id.uuidString)
        let snapshot = try await query.getDocuments()
        var result: [CommentPayload] = []
        for doc in snapshot.documents {
            do {
                let comment = try doc.data(as: CommentPayload.self)
                result.append(comment)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func getAllComments() async throws -> [CommentPayload] {
        let snapshot = try await fs.collection(Collections.comments).getDocuments()
        var result: [CommentPayload] = []
        for doc in snapshot.documents {
            do {
                let comment = try doc.data(as: CommentPayload.self)
                result.append(comment)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func setUserStatus(_ userStatus: UserStatus) async throws {
        try await self.db.child(Collections.statuses)
            .child(String(userStatus.userId))
            .setValue(userStatus.dictionary())
    }
    
    public func getUserStatus(_ id: Int) async throws -> UserStatus {
        let snapshot = try await self.db.child(Collections.statuses)
            .child(String(id))
            .getData()
        guard let value = snapshot.value,
              let dict = value as? NSDictionary
        else {
            throw ParsingError.error
        }
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        let result = try JSONDecoder().decode(UserStatus.self, from: jsonData)
        return result
    }
    
    public func getAllUsersStatuses() async throws -> [UserStatus] {
        let snapshot = try await self.db.child(Collections.statuses).getData()
        guard let value = snapshot.value,
              let dict = value as? NSDictionary
        else {
            throw ParsingError.error
        }
        let jsonData = try JSONSerialization.data(withJSONObject: dict.allValues, options: [])
        let result = try JSONDecoder().decode([UserStatus].self, from: jsonData)
        return result
    }
    
    public func addPost(_ post: PostPayload) async throws {
        try await self.fs.collection(Collections.posts).document(post.id.uuidString).setData(post.dictionary())
    }
      
    public func getAllPosts() async throws -> [PostPayload] {
        let snapshot = try await fs.collection(Collections.posts).getDocuments()
        var result: [PostPayload] = []
        for doc in snapshot.documents {
            do {
                let post = try doc.data(as: PostPayload.self)
                result.append(post)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func getPost(_ id: UUID) async throws -> PostPayload {
        try await fs.collection(Collections.posts).document(id.uuidString).getDocument(as: PostPayload.self)
    }
    
    public func getUsersPosts(userId: Int) async throws -> [PostPayload] {
        let collection = fs.collection(Collections.posts)
        let query = collection.whereField("userId", isEqualTo: userId)
        let snapshot = try await query.getDocuments()
        var result: [PostPayload] = []
        for doc in snapshot.documents {
            do {
                let post = try doc.data(as: PostPayload.self)
                result.append(post)
            } catch {
                continue
            }
        }
        return result
    }
    
    public func getHomePosition() -> Position {
        return Position(lat: 37.78, lng: -122.40)
    }
    
    public func uploadImage(image: Data) async throws -> URL {
        let ref = storage.child("Images").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        let _ = try await ref.putDataAsync(image, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
    
    public func uploadVideo(video: Data) async throws -> URL {
        let ref = storage.child("Videos").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        let _ = try await ref.putDataAsync(video, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
}
