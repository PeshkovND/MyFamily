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

    private enum PhoneFieldState {
        case enteringStarted
        case enteredOnce
    }

    @Published private var phoneNumberText: String = ""

    private let signInInteractor: SignInInteractor

    private var strings = appDesignSystem.strings
    private var phoneFieldState: PhoneFieldState = .enteringStarted
    private var validField: String { "number" }

    init(signInInteractor: SignInInteractor) {
        self.signInInteractor = signInInteractor
        super.init()

        subscribeToPhoneNumberChanges()
    }

    override func onViewEvent(_ event: SignInViewEvent) {
        switch event {
        case .actionNext(let text):
            phoneNumberText = text
        case .deinit:
            outputEventSubject.send(.back)
        case .viewDidLoad:
            viewState = .initial
        case .phoneEdited(let text):
            handlePhoneInput(text)
        }
    }

    private func handlePhoneInput(_ text: String) {
        let hasValidPhoneLength = text.count == GlobalConfig.PhoneNumber.validInputPhoneLength

        if hasValidPhoneLength && phoneFieldState == .enteringStarted {
            phoneFieldState = .enteredOnce
            viewState = .inputValidated(
                .init(inputError: nil, actionEnabled: true)
            )
            return
        }

        guard phoneFieldState == .enteredOnce else { return }

        if hasValidPhoneLength {
            viewState = .inputValidated(
                .init(inputError: nil, actionEnabled: true)
            )
        } else {
            viewState = .inputValidated(
                .init(inputError: "Fill your phone number", actionEnabled: false)
            )
        }
    }

    private func subscribeToPhoneNumberChanges() {
        $phoneNumberText
            .filter {
                !$0.isEmpty
            }
            .map { [weak self] (formattedPhoneNumber: String) -> String in
                guard let self = self else { return "" }
                return self.normalizePhoneNumber(text: formattedPhoneNumber)
            }
            .flatMap { [weak self] phoneNumber -> AnyPublisher<Result<Void, AppError>, Never> in

                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }

                self.viewState = .loading

                return self.signInInteractor.requestAuth(phoneNumber: phoneNumber)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.viewState = .loaded
                    self.outputEventSubject.send(.continue)
                case .failure(let error):
                    if let uiError = self.makeScreenError(from: error) {
                        self.viewState = .failed(error: uiError)
                    }
                }
            }
            .store(in: &cancelableSet)
    }

    /// Remove formatting symbos
    /// - Parameter text: Phone number in form of `(234) 567-8900`
    /// - Returns: Normalized phone number `12345678900`
    private func normalizePhoneNumber(text: String) -> String {
        let trimmedPhoneNumber = text.filter(GlobalConfig.PhoneNumber.validDigits.contains)
        let phoneNumber: String = GlobalConfig.PhoneNumber.countryCode + trimmedPhoneNumber
        return phoneNumber
    }

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
