import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import SwiftData

private final class Collections {
    static let posts = "Posts"
    static let users = "Users"
    static let comments = "Comments"
    static let statuses = "Statuses"
}

public enum FirebaseClientError: Error {
    case parsingError
    case fetchingError
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

public class FirebaseClient {

    private var fs: Firestore
    private var db: DatabaseReference
    private lazy var storage = Storage.storage().reference()
    
    public init() {
        FirebaseApp.configure()
        let db = Database.database()
        db.isPersistenceEnabled = false
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let fs = Firestore.firestore()
        fs.settings = settings
        self.fs = fs
        self.db = db.reference()
    }
    
    public func addUser(_ user: UserInfo) async throws -> Result<UserInfo,FirebaseClientError> {
        let dbUserResult = try await getUser(user.id)
        switch dbUserResult {
        case .success(let dbUser):
            let userInfo = UserInfo(
                id: dbUser.id,
                photoURL: dbUser.photoURL,
                firstName: dbUser.firstName,
                lastName: dbUser.lastName
            )
            return .success(userInfo)
        case .failure(let e):
            switch e {
            case .fetchingError:
                return .failure(.fetchingError)
            case .parsingError:
                let userPayload = UserPayload(
                    id: user.id,
                    photoURL: user.photoURL,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    role: .regular,
                    pro: false
                )
                try await self.fs.collection(Collections.users).document(String(user.id)).setData(userPayload.dictionary())
                return .success(user)
            }
        }
    }
    
    public func setProStatus(userId: Int) async throws {
        var result = try await getUser(userId)
        switch result {
        case .success(var user):
            user.pro = true
            try await self.fs.collection(Collections.users).document(String(user.id)).setData(user.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    public func updateUser(_ user: UserInfo) async throws {
        let document = try await fs.collection(Collections.users).document(String(user.id)).getDocument(as: UserPayload.self)
        
        let user = UserPayload(
            id: user.id,
            photoURL: user.photoURL,
            firstName: user.firstName,
            lastName: user.lastName,
            role: document.role,
            pro: document.pro
        )
        try await self.fs.collection(Collections.users).document(String(user.id)).setData(user.dictionary())
    }
    
    public func getUser(_ id: Int) async throws -> Result<UserPayload, FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.users).document(String(id)).getDocument()
            if snapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }
            return .success(try snapshot.data(as: UserPayload.self))
        } catch let e as DecodingError {
            return .failure(.parsingError)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func getAllUsers() async throws -> Result<[UserPayload], FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.users).getDocuments(source: .server)
            if snapshot.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            var result: [UserPayload] = []
            for doc in snapshot.documents {
                do {
                    let user = try doc.data(as: UserPayload.self)
                    result.append(user)
                } catch {
                    continue
                }
            }
            return .success(result)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func addComment(_ comment: CommentPayload) async throws {
        try await self.fs.collection(Collections.comments)
            .document(comment.id.uuidString)
            .setData(comment.dictionary())
    }
    
    public func getCommentsOnPost(_ id: UUID) async throws -> Result<[CommentPayload], FirebaseClientError> {
        do {
            let collection = fs.collection(Collections.comments)
            let query = collection.whereField("postId", isEqualTo: id.uuidString).order(by: "date")
            let snapshot = try await query.getDocuments()
            if snapshot.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            var result: [CommentPayload] = []
            for doc in snapshot.documents {
                do {
                    let comment = try doc.data(as: CommentPayload.self)
                    result.append(comment)
                } catch {
                    continue
                }
            }
            return .success(result)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func getAllComments() async throws -> Result<[CommentPayload], FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.comments).getDocuments()
            if snapshot.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            var result: [CommentPayload] = []
            for doc in snapshot.documents {
                do {
                    let comment = try doc.data(as: CommentPayload.self)
                    result.append(comment)
                } catch {
                    continue
                }
            }
            return .success(result)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func setUserStatus(_ userStatus: UserStatus) async throws {
        try await self.db.child(Collections.statuses)
            .child(String(userStatus.userId))
            .setValue(userStatus.dictionary())
    }
    
    public func getUserStatus(_ id: Int) async throws -> Result<UserStatus, FirebaseClientError> {
        let connectionTest = try await self.getAllUsers()
        switch connectionTest {
        case .success:
            do {
                let snapshot = try await self.db.child(Collections.statuses)
                    .child(String(id))
                    .getData()
                guard let value = snapshot.value,
                      let dict = value as? NSDictionary
                else {
                    throw FirebaseClientError.parsingError
                }
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                let result = try JSONDecoder().decode(UserStatus.self, from: jsonData)
                return .success(result)
            } catch {
                return .failure(.fetchingError)
            }
        case .failure(_):
            return .failure(.fetchingError)
        }
    }
    
    public func getAllUsersStatuses() async throws -> Result<[UserStatus], FirebaseClientError> {
        let connectionTest = try await self.getAllUsers()
        switch connectionTest {
        case .success:
            do {
                let snapshot = try await self.db.child(Collections.statuses).getData()
                guard let value = snapshot.value,
                      let dict = value as? NSDictionary
                else {
                    throw FirebaseClientError.parsingError
                }
                let jsonData = try JSONSerialization.data(withJSONObject: dict.allValues, options: [])
                let result = try JSONDecoder().decode([UserStatus].self, from: jsonData)
                return .success(result)
            } catch {
                return .failure(.fetchingError)
            }
        case .failure:
            return .failure(.fetchingError)
        }
    }
    
    public func addPost(_ post: PostPayload) async throws {
        try await self.fs.collection(Collections.posts).document(post.id.uuidString).setData(post.dictionary())
    }
      
    public func getAllPosts() async throws -> Result<[PostPayload], FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.posts)
                .order(by: "date", descending: true)
                .getDocuments()
            if snapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }
            var result: [PostPayload] = []
            for doc in snapshot.documents {
                do {
                    let post = try doc.data(as: PostPayload.self)
                    result.append(post)
                } catch {
                    continue
                }
            }
            return .success(result)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func getPost(_ id: UUID) async throws -> Result<PostPayload, FirebaseClientError> {
        do {
            let document = try await fs.collection(Collections.posts).document(id.uuidString).getDocument()
            if document.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            return .success(try document.data(as: PostPayload.self))
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func getUsersPosts(userId: Int) async throws -> Result<[PostPayload], FirebaseClientError> {
        do {
            let collection = fs.collection(Collections.posts)
            let query = collection.whereField("userId", isEqualTo: userId).order(by: "date", descending: true)
            let snapshot = try await query.getDocuments()
            if snapshot.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            var result: [PostPayload] = []
            for doc in snapshot.documents {
                do {
                    let post = try doc.data(as: PostPayload.self)
                    result.append(post)
                } catch {
                    continue
                }
            }
            return .success(result)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    public func getHomePosition() -> Position {
        return Position(lat: 37.78, lng: -122.40)
    }
    
    public func uploadImage(image: Data) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Images").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(image, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
    
    public func uploadVideo(video: Data) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Videos").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        _ = try await ref.putDataAsync(video, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
    
    public func uploadAudio(url: URL) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Audio").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "audio"
        _ = try await ref.putFileAsync(from: url)
        return try await ref.downloadURL()
    }
    
    public func unwrapResult<T>(
        result: Result<T, FirebaseClientError>,
        successAction: (T) async throws -> Void,
        failureAction: () async throws -> T?
    ) async throws -> T? {
        switch result {
        case .success(let resultPayload):
            do {
                try await successAction(resultPayload)
                return resultPayload
            } catch let e {
                throw e
            }
        case .failure(_):
            do {
                if let unwrappedData = try await failureAction() {
                    return unwrappedData
                } else {
                    return nil
                }
            } catch let e {
                throw e
            }
        }
    }
}
