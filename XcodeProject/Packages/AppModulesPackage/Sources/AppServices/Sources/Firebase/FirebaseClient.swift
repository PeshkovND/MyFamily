import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

enum Role: String, Codable {
    case owner
    case regular
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
        db.collection("users").document(String(user.id)).getDocument { (document, error) in
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
                try self.db.collection("users").document(String(user.id)).setData(from: user) { error in
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
}
