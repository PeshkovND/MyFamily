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
        let input = PhoneNumberInput(
            phoneNumber,
            countryCode: GlobalConfig.PhoneNumber.countryCode,
            nationalLength: GlobalConfig.PhoneNumber.validInputPhoneLength
        )
        guard input.isValid else {
            return Just<Result<Void, AppError>>(.failure(.unexpected))
                .eraseToAnyPublisher()
        }
        storePhoneNumber(input.requestValue)
        return authService.requestAuth(phoneNumber: input.requestValue)
    }

    func confirm(smsCode: String) -> AnyPublisher<Result<AuthState, AppError>, Never> {
        let input = SmsCodeInput(
            smsCode,
            requiredLength: GlobalConfig.SmsCode.validInputSmsLength
        )
        guard input.isValid else {
            return Just<Result<AuthState, AppError>>(.failure(.unexpected))
                .eraseToAnyPublisher()
        }
        return authService.confirm(phoneNumber: phoneNumber, smsCode: input.requestValue)
    }

    private func storePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
 }
