import VKID
import AppEntities

public final class VKIDClient {
    public var vkid: VKID
    private let firebaseClient: FirebaseClient
    
    public init(firebaseClient: FirebaseClient) {
        self.firebaseClient = firebaseClient
        do {
            vkid = try VKID(
                config: Configuration(
                    appCredentials: AppCredentials(
                        clientId: "51879243",
                        clientSecret: "pOg3b9a2oLiBnG3xWBL6"
                    )
                )
            )
        } catch {
            preconditionFailure("Failed to initialize VKID: \(error)")
        }
    }
    
    public func authorize(onSuccess: @escaping (Credentials) -> Void, onFailure: @escaping () -> Void) {
        vkid.authorize(
            using: .newUIWindow
            // swiftlint:disable closure_body_length
        ) { result in
            do {
                let session = try result.get()
                print("Auth succeeded with token: \(session.accessToken) and user info: \(session.user)")
                let credentials = Credentials(accessToken: session.accessToken.value, expirationDate: session.accessToken.expirationDate)
                let userInfo = UserInfo(
                    id: session.user.id.value,
                    photoURL: session.user.avatarURL,
                    firstName: session.user.firstName,
                    lastName: session.user.lastName
                )
                self.firebaseClient.addUser(
                    userInfo,
                    onSuccess: { onSuccess(credentials) },
                    onFailure: onFailure
                )
            } catch AuthError.cancelled {
                print("Auth cancelled by user")
            } catch let error {
                print("Auth failed with error: \(error)")
                onFailure()
            }
        }
    }
    
    public func logout(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        vkid.currentAuthorizedSession?.logout { result in
            switch result {
            case .success:
                onSuccess()
            case .failure:
                onFailure()
            }
        }
    }
}
