import VKID
import Foundation
import AppEntities

public final class VKIDClient {
    public var vkid: VKID
    private let firebaseClient: FirebaseClient
    private let env: Env
    
    public init(firebaseClient: FirebaseClient, env: Env) {
        self.firebaseClient = firebaseClient
        self.env = env
        do {
            vkid = try VKID(
                config: Configuration(
                    appCredentials: AppCredentials(
                        clientId: env.vkidClientId,
                        clientSecret: env.vkidClientSecret
                    )
                )
            )
        } catch {
            preconditionFailure("Failed to initialize VKID: \(error)")
        }
    }
    
    public func authorize(onSuccess: @escaping (Credentials, UserInfo) -> Void, onFailure: @escaping () -> Void) {
        vkid.authorize(
            using: .newUIWindow
            // swiftlint:disable closure_body_length
        ) { result in
            do {
                let session = try result.get()
                print("Auth succeeded with token: \(session.accessToken) and user info: \(session.user)")
                let credentials = Credentials(
                    accessToken: session.accessToken.value,
                    expirationDate: session.accessToken.expirationDate
                )
                let userInfoPayload = UserInfo(
                    id: session.user.id.value,
                    photoURL: session.user.avatarURL,
                    firstName: session.user.firstName,
                    lastName: session.user.lastName
                )
                Task {
                    do {
                        let userInfoResult = try await self.firebaseClient.addUser(userInfoPayload)
                        await MainActor.run {
                            switch userInfoResult {
                            case .success(let userInfo):
                                onSuccess(credentials, userInfo)
                            case .failure:
                                onFailure()
                            }
                        }
                    } catch {
                        await MainActor.run {
                            onFailure()
                        }
                    }
                }
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
