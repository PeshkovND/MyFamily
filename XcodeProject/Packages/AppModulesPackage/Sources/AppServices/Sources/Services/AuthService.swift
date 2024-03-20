//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities

// MARK: - AuthState
public enum AuthState {
    case signIn
    case signUp
}

// MARK: - CredentialsProvider

public protocol CredentialsProvider {
    var credentials: Credentials? { get }
}

// MARK: - AccountHolder

public protocol AccountHolder {
    var account: UserInfo? { get }
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
    func requestAuth(phoneNumber: String) -> AnyPublisher<Result<Void, AppError>, Never>
    func confirm(phoneNumber: String, smsCode: String) -> AnyPublisher<Result<AuthState, AppError>, Never>
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
    public var account: UserInfo? { provideAccount() }

    public var onLogoutCompleted: () -> Void = {}
    public var onAuthErrorOccured: () -> Void = {}

    private let providingHttpClient: () -> AlamofireHttpClient
    private let requestFactory: HttpRequestFactory
    private let defaultsStorage: DefaultsStorage
    private let networkMapper: NetworkMapper

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
        networkMapper: NetworkMapper,
        defaultsStorage: DefaultsStorage,
        vkIdClient: VKIDClient
    ) {
        self.providingHttpClient = providingHttpClient
        self.requestFactory = requestFactory
        self.networkMapper = networkMapper
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

    public func requestAuth(
        phoneNumber: String
    ) -> AnyPublisher<Result<Void, AppError>, Never> {

        removeAccountWithCredentials()

        let publisher = httpClient.sendRequest(
            requestFactory.requestAuth(uuid: deviceId, number: phoneNumber),
            payloadType: String.self
        )
        .flatMap { (result: Result<String, AppError>) -> Just<Result<Void, AppError>> in
            switch result {
            case .success:
                return Just<Result<Void, AppError>>(
                    .success(())
                )
            case .failure(let appError):
                return Just<Result<Void, AppError>>(
                    .failure(appError)
                )
            }
        }
        .eraseToAnyPublisher()

        return publisher
    }

    public func confirm(
        phoneNumber: String,
        smsCode: String
    ) -> AnyPublisher<Result<AuthState, AppError>, Never> {

        let publisher = httpClient.sendRequest(
            requestFactory.confirmAuth(uuid: deviceId, number: phoneNumber, code: smsCode),
            payloadType: AuthorizedUserPayload.self
        )
        .flatMap { [weak self] (result: Result<AuthorizedUserPayload, AppError>)
            -> Just<Result<AuthState, AppError>> in

            guard let self = self else {
                return Just<Result<AuthState, AppError>>(
                    .failure(.unexpected)
                )
            }
            return self.handleConfirmResponse(result)
        }
        .eraseToAnyPublisher()

        return publisher
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

    private func handleConfirmResponse(
        _ result: Result<AuthorizedUserPayload, AppError>
    ) -> Just<Result<AuthState, AppError>> {
        switch result {
        case .success(let payload):
            let mappedPayload = networkMapper.accountWithCreds(from: payload)
            let account = mappedPayload.account
            let credentials = mappedPayload.credentials

            self.saveCredentials(credentials)

            let authState: AuthState = account.alreadyRegistered ? .signIn : .signUp

            return Just<Result<AuthState, AppError>>(
                .success(authState)
            )

        case .failure(let appError):
            return Just<Result<AuthState, AppError>>(
                .failure(appError)
            )
        }
    }

    private func handleRefreshResponse(
        _ result: Result<AuthorizedUserPayload, AppError>
    ) -> Just<Result<Credentials, AppError>> {
        switch result {
        case .success(let payload):
            let mappedPayload = networkMapper.accountWithCreds(from: payload)
            let account = mappedPayload.account
            let credentials = mappedPayload.credentials
            
            self.saveCredentials(credentials)

            return Just<Result<Credentials, AppError>>(
                .success(credentials)
            )

        case .failure(let appError):
            return Just<Result<Credentials, AppError>>(
                .failure(appError)
            )
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

    private func provideAccount() -> UserInfo? {
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
