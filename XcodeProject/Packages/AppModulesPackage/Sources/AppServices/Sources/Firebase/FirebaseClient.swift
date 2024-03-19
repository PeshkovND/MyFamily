import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

enum Role: String, Codable {
    case owner
    case regular
}

enum ContentType: String, Codable {
    case video
    case image
    case audio
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
    
    public init() {
    }
    
    public func addUser(
        _ user: UserInfo,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        // swiftlint:disable closure_body_length
        db.collection("Users").document(String(user.id)).getDocument { (document, error) in
            guard error == nil, let document = document else { onFailure(); return }
            guard !document.exists else { onSuccess(); return }
            do {
                let user = UserPayload(
                    id: user.id,
                    photoURL: user.photoURL,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: .regular,
                    pro: false
                )
                try self.db.collection("Users").document(String(user.id)).setData(from: user) { error in
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
