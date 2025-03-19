import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import SwiftData
import AppEntities

private final class Collections {
    static let posts = "Posts"
    static let users = "Users"
    static let comments = "Comments"
    static let statuses = "Statuses"
    static let families = "Families"
    static let invitations = "Invitations"
}

public enum FirebaseClientError: Error {
    case parsingError
    case fetchingError
    case documentAlreadyExists
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
}

public extension FirebaseClient {
    
    func addFamily(_ family: FamilyPayload) async throws {
        let test = try await getAllUsers()
        switch test {
        case .success:
            try await self.fs.collection(Collections.families)
                .document(family.id.uuidString)
                .setData(family.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    func addUser(_ user: UserInfo) async throws -> Result<UserInfo, FirebaseClientError> {
        let dbUserResult = try await getUser(user.id)
        switch dbUserResult {
        case .success(let dbUser):
            let userInfo = UserInfo(
                id: dbUser.id,
                photoURL: dbUser.photoURL,
                firstName: dbUser.firstName,
                lastName: dbUser.lastName,
                familyId: dbUser.familyId
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
                    pro: false,
                    familyId: user.familyId
                )
                try await self.fs.collection(Collections.users).document(String(user.id)).setData(userPayload.dictionary())
                return .success(user)
            case .documentAlreadyExists:
                return .failure(.documentAlreadyExists)
            }
        }
    }
    
    func setProStatus(userId: Int, status: Bool) async throws {
        let result = try await getUser(userId)
        switch result {
        case .success(var user):
            user.pro = status
            try await self.fs.collection(Collections.users).document(String(user.id)).setData(user.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    func getInvitations(familyId: String) async throws -> Result<[InvitePayload], FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.invitations)
                .whereField("familyId", isEqualTo: familyId)
                .getDocuments(source: .server)
            if snapshot.metadata.isFromCache {
                return .failure(.fetchingError)
            }
            var result: [InvitePayload] = []
            for doc in snapshot.documents {
                do {
                    let user = try doc.data(as: InvitePayload.self)
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
    
    func addInvitations(invitePayload: InvitePayload) async throws {
        let dbInvitationResult = try await getInvitation(invitePayload.id)
        switch dbInvitationResult {
        case .success(let dbUser):
            throw FirebaseClientError.documentAlreadyExists
        case .failure(let e):
            switch e {
            case .fetchingError:
                throw FirebaseClientError.fetchingError
            case .parsingError:
                try await self.fs.collection(Collections.invitations).document(invitePayload.id).setData(invitePayload.dictionary())
            case .documentAlreadyExists:
                break
            }
        }
    }
    
    func deleteInvitations(id: String) async throws {
        let test = try await getAllUsers()
        switch test {
        case .success:
            try await self.fs.collection(Collections.invitations)
                .document(id)
                .delete()
        case .failure(let e):
            throw e
        }
    }
    
    func updateUser(_ user: UserInfo) async throws {
        let result = try await getUser(user.id)
        switch result {
        case .success(let document):
            let user = UserPayload(
                id: user.id,
                photoURL: user.photoURL,
                firstName: user.firstName,
                lastName: user.lastName,
                role: document.role,
                pro: document.pro,
                familyId: user.familyId
            )
            try await self.fs.collection(Collections.users).document(String(user.id)).setData(user.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    func getUser(_ id: Int) async throws -> Result<UserPayload, FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.users).document(String(id)).getDocument()
            if snapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }
            return .success(try snapshot.data(as: UserPayload.self))
        } catch _ as DecodingError {
            return .failure(.parsingError)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    func getInvitation(_ id: String) async throws -> Result<InvitePayload, FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.invitations).document(String(id)).getDocument()
            if snapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }
            return .success(try snapshot.data(as: InvitePayload.self))
        } catch _ as DecodingError {
            return .failure(.parsingError)
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    func getAllUsers(familyId: String) async throws -> Result<[UserPayload], FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.users)
                .whereField("familyId", isEqualTo: familyId)
                .getDocuments(source: .server)
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
    
    func getAllUsers() async throws -> Result<[UserPayload], FirebaseClientError> {
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
}

public extension FirebaseClient {
    func addComment(_ comment: CommentPayload) async throws {
        let test = try await getAllUsers()
        switch test {
        case .success:
            try await self.fs.collection(Collections.comments)
                .document(comment.id.uuidString)
                .setData(comment.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    func getCommentsOnPost(_ id: UUID) async throws -> Result<[CommentPayload], FirebaseClientError> {
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
    
    func getAllComments() async throws -> Result<[CommentPayload], FirebaseClientError> {
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
}

public extension FirebaseClient {
    
    func getHomePosition(familyId: String) async throws -> Result<Position, FirebaseClientError> {
        do {
            let snapshot = try await fs.collection(Collections.families).document(familyId).getDocument()
            if snapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }
            let family = try snapshot.data(as: FamilyPayload.self)
            return .success(.init(lat: family.homeLatitude, lng: family.homeLongitude))
        } catch {
            return .failure(.fetchingError)
        }
    }
    
    func setUserStatus(_ userStatus: UserStatus) async throws {
        try await self.db.child(Collections.statuses)
            .child(String(userStatus.userId))
            .setValue(userStatus.dictionary())
    }
    
    func setUserCoordinates(userId: Int, coordinates: Position) async throws {
        let result = try await getUserStatus(userId)
        switch result {
        case .success(let lastUserStatus):
            let currentUserStatus = UserStatus(
                userId: userId,
                lastOnline: lastUserStatus.lastOnline,
                position: coordinates
            )
            try await self.db.child(Collections.statuses)
                .child(String(currentUserStatus.userId))
                .setValue(currentUserStatus.dictionary())
        case .failure(let error):
            throw error
        }
    }
    
    func getUserStatus(_ id: Int) async throws -> Result<UserStatus, FirebaseClientError> {
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
        case .failure:
            return .failure(.fetchingError)
        }
    }
    
    func getAllUsersStatuses() async throws -> Result<[UserStatus], FirebaseClientError> {
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
}

public extension FirebaseClient {
    func addPost(_ post: PostPayload) async throws {
        let connectionTest = try await self.getAllUsers()
        switch connectionTest {
        case .success:
            try await self.fs.collection(Collections.posts).document(post.id.uuidString).setData(post.dictionary())
        case .failure(let e):
            throw e
        }
    }
    
    func getAllPosts(forFamilyId familyId: String) async throws -> Result<[PostPayload], FirebaseClientError> {
        do {
            let usersSnapshot = try await fs.collection(Collections.users)
                .whereField("familyId", isEqualTo: familyId)
                .getDocuments()

            if usersSnapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }

            let userIds = usersSnapshot.documents.map { Int($0.documentID) }

            if userIds.isEmpty {
                return .success([])
            }

            let postsSnapshot = try await fs.collection(Collections.posts)
                .whereField("userId", in: userIds) // Используем оператор "in" для фильтрации по userId
                .order(by: "date", descending: true)
                .getDocuments()

            if postsSnapshot.metadata.isFromCache {
                return .failure(FirebaseClientError.fetchingError)
            }

            var result: [PostPayload] = []
            for doc in postsSnapshot.documents {
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
    
    
    func getAllPosts() async throws -> Result<[PostPayload], FirebaseClientError> {
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
    
    func getPost(_ id: UUID) async throws -> Result<PostPayload, FirebaseClientError> {
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
    
    func getUsersPosts(userId: Int) async throws -> Result<[PostPayload], FirebaseClientError> {
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
}

public extension FirebaseClient {
    func uploadImage(image: Data) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Images").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(image, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
    
    func uploadVideo(video: Data) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Videos").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "video/mp4"
        _ = try await ref.putDataAsync(video, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
    
    func uploadAudio(audio: Data) async throws -> URL {
        storage.storage.maxUploadRetryTime = 30
        let ref = storage.child("Audio").child(UUID().uuidString)
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "audio"
        _ = try await ref.putDataAsync(audio, metadata: uploadMetadata)
        return try await ref.downloadURL()
    }
}

public extension FirebaseClient {
    func unwrapResult<T>(
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
        case .failure:
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
