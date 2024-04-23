//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities

// MARK: - AuthState
public enum AuthState {
    case signIn
}

// MARK: - CredentialsProvider

public protocol CredentialsProvider {
    var credentials: Credentials? { get }
}

// MARK: - AccountHolder

public protocol AccountHolder {
    var account: Account? { get }
    var hasFilledProfile: Bool { get }
    func updateAccount(_ account: UserInfo)
}

// MARK: - AccountHolder

public protocol LogoutNotifier {
    var onLogoutCompleted: () -> Void { get set }
    var onAuthErrorOccured: () -> Void { get set }
}

// MARK: - AuthService

public protocol AuthService: CredentialsProvider, AccountHolder, LogoutNotifier {

    var hasAuthorizedUser: Bool { get }

    func signIn(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
    func logout(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void)
}

// MARK: - AppAuthService

public final class AppAuthService: AuthService {

    typealias VoidResult = Result<Void, AppError>

    private static var logger: Logger { LoggerFactory.default }

    public var hasAuthorizedUser: Bool {
        guard let credentials = credentials else { return false }
        return credentials.expirationDate > Date()
    }

    public var hasFilledProfile: Bool {
        let profile = account
        let hasFirstName = profile?.firstName.isNotEmpty ?? false
        let hasLastName = profile?.lastName.isNotEmpty ?? false
        let hasDisplayName = profile?.firstName != nil

        return hasFirstName && hasLastName && hasDisplayName
    }

    public var credentials: Credentials? { provideCredentials() }
    public var account: Account? { provideAccount() }

    public var onLogoutCompleted: () -> Void = {}
    public var onAuthErrorOccured: () -> Void = {}

    private let providingHttpClient: () -> AlamofireHttpClient
    private let requestFactory: HttpRequestFactory
    private let defaultsStorage: DefaultsStorage

    private var deviceIdKey: String { "\(Self.self).deviceIdKey" }
    private var deviceId: String { provideDeviceId() }
    private var uiDevice: UIDevice { .current }

    private var accountKey: String { "\(Self.self).accountKey" }
    private var credentialsKey: String { "\(Self.self).credentialsKey" }

    private var httpClient: AlamofireHttpClient { providingHttpClient() }
    private let vkIdClient: VKIDClient

    public init(
        providingHttpClient: @escaping () -> AlamofireHttpClient,
        requestFactory: HttpRequestFactory,
        defaultsStorage: DefaultsStorage,
        vkIdClient: VKIDClient
    ) {
        self.providingHttpClient = providingHttpClient
        self.requestFactory = requestFactory
        self.defaultsStorage = defaultsStorage
        self.vkIdClient = vkIdClient
    }
    
    public func signIn(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        vkIdClient.authorize(
            onSuccess: { credentials, userInfo in
                self.saveCredentials(credentials)
                self.saveAccount(userInfo)
                onSuccess()
            },
            onFailure: {
                onFailure()
            }
        )
    }

    public func logout(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        
        vkIdClient.logout(
            onSuccess: {
                self.removeAccountWithCredentials()
                onSuccess()
            },
            onFailure: onFailure
        )
    }

    public func updateAccount(_ account: UserInfo) {
        saveAccount(account)
    }
}

// MARK: - String as Payloadable

extension String: Payloadable {}

// MARK: - Helpers

private extension AppAuthService {

    func provideDeviceId() -> String {
        let cachedDeviceId: String? = defaultsStorage.primitiveValue(
            forKey: deviceIdKey
        )

        if let deviceId = cachedDeviceId {
            return deviceId
        } else {
            let generatedId = generateDeviceId()
            defaultsStorage.add(primitiveValue: generatedId, forKey: deviceIdKey)
            return generatedId
        }
    }

    private func generateDeviceId() -> String {
        let idForVendor = uiDevice.identifierForVendor?.uuidString
        
        if let id = idForVendor {
            return id
        } else {
            let randomId = UUID().uuidString
            return randomId
        }
    }

    private func saveAccount(_ account: UserInfo) {
        defaultsStorage.add(object: account, forKey: accountKey)
    }

    private func saveCredentials(_ credentials: Credentials) {
        // IMPLEMENT: Replace with secure storage
        defaultsStorage.add(object: credentials, forKey: credentialsKey)
    }

    private func provideCredentials() -> Credentials? {
        defaultsStorage.object(forKey: credentialsKey)
    }

    private func provideAccount() -> Account? {
        defaultsStorage.object(forKey: accountKey)
    }

    private func removeAccountWithCredentials() {
        defaultsStorage.removeObject(forKey: accountKey)
        defaultsStorage.removeObject(forKey: credentialsKey)
    }

    private func notifyThatLogoutCompleted() {
        DispatchQueue.main.async {
            self.onLogoutCompleted()
        }
    }

    private func notifyThatAuthErrorOccured() {
        DispatchQueue.main.async {
            self.onAuthErrorOccured()
        }
    }
}
