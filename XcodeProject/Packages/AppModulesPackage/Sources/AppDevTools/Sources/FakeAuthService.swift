//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine
import AppEntities
import AppServices
import Alamofire

public final class StubAuthInterceptor: RequestInterceptor {

    public init() {}
}

public final class FakeAuthService: AuthService {
    private static var logger = LoggerFactory.default
    public var hasAuthorizedUser: Bool { false }
    public var hasFilledProfile: Bool { false }
    public var credentials: Credentials? { nil }
    public var account: Account? { nil }
    public func updateAccount(_ account: UserInfo) {}
    public var onLogoutCompleted: () -> Void = {}
    public var onAuthErrorOccured: () -> Void = {}

    public init() {}
    
    public func signIn(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) { }
    
    public func logout(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) { }

    public func requestAuth(phoneNumber: String) -> AnyPublisher<Result<Void, AppError>, Never> {
        Just<Result<Void, AppError>>(
            .success(())
        )
        .delay(for: .seconds(3.0), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func confirm(phoneNumber: String, smsCode: String) -> AnyPublisher<Result<AuthState, AppError>, Never> {
        Just<Result<AuthState, AppError>>(
            .success(.signIn)
        )
        .delay(for: .seconds(3.0), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func refreshToken() -> AnyPublisher<Result<Credentials, AppError>, Never> {
        Empty().eraseToAnyPublisher()
    }

    public func logout() -> AnyPublisher<Result<Void, AppError>, Never> {
        // swiftlint:disable trailing_closure
        Just<Result<Void, AppError>>(
            .success(())
        )
        .delay(for: .seconds(0.3), scheduler: DispatchQueue.main)
        .handleEvents(receiveOutput: { [weak self] _ in
            Self.logger.debug(message: "Logout completed!")
            self?.onLogoutCompleted()
        })
        .eraseToAnyPublisher()
        // swiftlint:enable trailing_closure
    }
}
