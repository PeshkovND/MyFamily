//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class SignInViewModel: BaseViewModel<SignInViewEvent,
                                               SignInViewState,
                                               SignInOutputEvent> {
    
    private var strings = appDesignSystem.strings
    private var validField: String { "number" }
    fileprivate let authService: AuthService
    
    init (authService: AuthService) {
        self.authService = authService
    }

    override func onViewEvent(_ event: SignInViewEvent) {
        switch event {
        case .signInTapped:
            signInTapped()
        case .deinit:
            outputEventSubject.send(.back)
        case .viewDidLoad:
            viewState = .initial
        }
    }
    
    func signInTapped() {
        authService.signIn(
            onSuccess: { self.outputEventSubject.send(.signedIn) },
            onFailure: { print("error") }
        )
    }

    /// Remove formatting symbos
    /// - Parameter text: Phone number in form of `(234) 567-8900`
    /// - Returns: Normalized phone number `12345678900`

    private func makeScreenError(from appError: AppError) -> SignInContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {

            case GlobalConfig.ErrorsApiCode.exceedLimitSMSCode:
                let seconds = generalError.message.removingRegexMatches(pattern: "\\D+")
                
                let screenError: SignInContext.ScreenError = .init(
                    alert: .init(
                        title: strings.commonError,
                        message: strings.signInErrorExceedLimitSmsCode(seconds: seconds ?? "")
                    ),
                    fieldsInfo: specificErrors
                        .first( where: { $0.field == validField })?.message
                )
                return screenError
            default:
                let screenError: SignInContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first( where: { $0.field == validField })?.message
                )
                return screenError
            }
        case .network:
            let screenError: SignInContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return SignInContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
