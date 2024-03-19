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
}

public class FirebaseClient {

    lazy var db = Firestore.firestore()
    lazy var ref = Database.database().reference()
    
    public init() {
    }
    
    public func addUser(_ user: UserInfo) async throws {
        do {
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
        
    }
    
    public func getUser(_ id: Int) async throws -> UserPayload {
        // swiftlint:disable closure_body_length
        try await db.collection("Users").document(String(id)).getDocument(as: UserPayload.self)
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
    
    public func addPost(
        _ post: PostPayload,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        do {
            try self.db.collection("Posts").document(post.id.uuidString).setData(from: post) { error in
                if error == nil {
                    onSuccess()
                } else {
                    onFailure()
                }
            }
        } catch {
            onFailure()
        }
    }
}
