//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine
import AppEntities
import AppServices
import AppBaseFlow

final class SignInInteractor {

    private(set) var phoneNumber: String = ""
    
    private let authService: AuthService

    private var setCancellable = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService
    }

    func requestAuth(phoneNumber: String) -> AnyPublisher<Result<Void, AppError>, Never> {
        storePhoneNumber(phoneNumber)
        return authService.requestAuth(phoneNumber: phoneNumber)
    }

    func confirm(smsCode: String) -> AnyPublisher<Result<AuthState, AppError>, Never> {
        authService.confirm(phoneNumber: phoneNumber, smsCode: smsCode)
    }

    private func storePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
 }
