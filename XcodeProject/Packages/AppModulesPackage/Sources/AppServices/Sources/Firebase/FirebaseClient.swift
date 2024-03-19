import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

enum ParsingError: Error {
    case error
}

enum Role: String, Codable {
    case owner
    case regular
}

enum ContentType: String, Codable {
    case video
    case image
    case audio
}

public struct Position: Codable {
    let lat: Double
    let lng: Double
    
    func dictionary() -> [String: Any] {
        return [
            "lat": lat,
            "lng": lng
        ]
    }
}

public struct CommentPayload: Codable {
    let id: UUID
    let userId: String
    let postId: UUID
    let text: String
    let date: String
    
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
    let userId: Int
    let lastOnline: String
    let position: Position
    
    func dictionary() -> [String: Any] {
        return [
            "userId": userId,
            "lastOnline": lastOnline,
            "position": position.dictionary()
        ]
    }
}

public struct UserInfo: Codable {
    let id: Int
    let photoURL: URL?
    let firstName: String
    let lastName: String
}

public struct UserPayload: Codable {
    let id: Int
    let photoURL: URL?
    let firstName: String
    let lastName: String
    let role: Role
    var pro: Bool
    
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
    let id: UUID
    let text: String?
    let contentURL: URL?
    let contentType: ContentType?
    let userId: Int
    let date: String
    let likes: [Int]
    
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

    lazy var db = Firestore.firestore()
    lazy var ref = Database.database().reference()
    
    public init() {}
    
    public func addUser(_ user: UserInfo) async throws {
        let document = try await db.collection("Users").document(String(user.id)).getDocument()
        guard !document.exists else { return }
        let user = UserPayload(
            id: user.id,
            photoURL: user.photoURL,
            firstName: user.firstName,
            lastName: user.lastName,
            role: .regular,
            pro: false
        )
        try await self.db.collection("Users").document(String(user.id)).setData(user.dictionary())
        
    }
    
    public func getUser(_ id: Int) async throws -> UserPayload {
        try await db.collection("Users").document(String(id)).getDocument(as: UserPayload.self)
    }
    
    public func getAllUsers(instead id: Int) async throws -> [UserPayload] {
        let snapshot = try await db.collection("Users").getDocuments()
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
    
    public func addComment(_ comment: CommentPayload) async throws {
        try await self.db.collection("Comments").document(comment.id.uuidString).setData(comment.dictionary())
    }
    
    public func getCommentsOnPost(_ id: UUID) async throws -> [CommentPayload] {
        let collection = db.collection("Comments")
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
    
    public func setUserStatus(_ userStatus: UserStatus) async throws {
        try await self.ref.child("Statuses").child(String(userStatus.userId)).setValue(userStatus.dictionary())
    }
    
    public func getUserStatus(_ id: Int) async throws -> UserStatus {
        let snapshot = try await self.ref.child("Statuses").child(String(id)).getData()
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
        let snapshot = try await self.ref.child("Statuses").getData()
        guard let value = snapshot.value,
              let dict = value as? NSDictionary
        else {
            print("aasas")
            throw ParsingError.error
        }
        let jsonData = try JSONSerialization.data(withJSONObject: dict.allValues, options: [])
        let result = try JSONDecoder().decode([UserStatus].self, from: jsonData)
        return result
    }
    
    public func addPost(_ post: PostPayload) async throws {
        try await self.db.collection("Posts").document(post.id.uuidString).setData(post.dictionary())
    }
    
    public func getAllPosts() async throws -> [PostPayload] {
        let snapshot = try await db.collection("Posts").getDocuments()
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
        try await db.collection("Posts").document(id.uuidString).getDocument(as: PostPayload.self)
    }
}
