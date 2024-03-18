import VKID

public final class VKIDClient {
    public var vkid: VKID
    
    public init() {
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
    
    public func authorize(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        vkid.authorize(
            using: .newUIWindow
        ) { result in
            do {
                let session = try result.get()
                print("Auth succeeded with token: \(session.accessToken) and user info: \(session.user)")
                onSuccess()
            } catch AuthError.cancelled {
                print("Auth cancelled by user")
            } catch {
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
