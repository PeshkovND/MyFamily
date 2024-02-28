//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Alamofire
import Combine
import AppEntities

// Based on: https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#authenticationinterceptor

public struct OAuthCredential: AuthenticationCredential {

    // Require refresh if within window interval in minutes of expiration
    public var requiresRefresh: Bool {
        guard let credentials = providingCredentials() else { return false }
        return refreshWindowDeadlineDate > credentials.expirationDate
    }

    var accessToken: String? { providingCredentials()?.accessToken }

    let refreshWindowTimeInterval: TimeInterval

    private let providingCredentials: () -> Credentials?

    private var refreshWindowDeadlineDate: Date {
        Date(timeIntervalSinceNow: refreshWindowTimeInterval)
    }

    public init(
        refreshWindowTimeInterval: TimeInterval,
        providingCredentials: @escaping () -> Credentials?
    ) {
        self.providingCredentials = providingCredentials
        self.refreshWindowTimeInterval = refreshWindowTimeInterval
    }
}

public final class OAuthAuthenticator: Authenticator {

    private static var logger: Logger { LoggerFactory.default }

    private let authService: AuthService
    private var cancelableSet: Set<AnyCancellable> = .init()

    private var unathorizedStatusCode: Int { 401 }

    public init(authService: AuthService) {
        self.authService = authService
    }

    public func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
        guard let accessToken = credential.accessToken else { return }
        urlRequest.headers.add(
            .authorization(bearerToken: accessToken)
        )
    }

    public func refresh(
        _ credential: OAuthCredential,
        for session: Session,
        completion: @escaping (Result<OAuthCredential, Error>) -> Void
    ) {
        authService.refreshToken()
            .sink { (result: Result<Credentials, AppError>) -> Void in
                switch result {
                case .success(let credentials):
                    let oauthCredential: OAuthCredential = .init(
                        refreshWindowTimeInterval: credential.refreshWindowTimeInterval,
                        providingCredentials: { credentials }
                    )
                    completion(.success(oauthCredential))
                case .failure(let error):
                    Self.logger.warning(message: error.localizedDescription)
                    completion(.failure(AppError.unathorized))
                }
            }
            .store(in: &cancelableSet)
    }

    public func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        let hasCredentials = authService.credentials != nil
        guard hasCredentials else { return false }
        return response.statusCode == unathorizedStatusCode
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
        guard let accessToken = credential.accessToken else { return false }

        let bearerToken = HTTPHeader.authorization(bearerToken: accessToken).value
        return urlRequest.headers["Authorization"] == bearerToken
    }
}
