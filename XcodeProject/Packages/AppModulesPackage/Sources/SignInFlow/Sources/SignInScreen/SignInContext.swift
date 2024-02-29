//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct SignInContext {
    private init() {}
}

// MARK: - Screen Error

extension SignInContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum SignInViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case inputValidated(_ validatingState: ValidatingState)
    case loading
    case loaded
    case failed(error: SignInContext.ScreenError)

    static var stub: SignInViewState { .initial }
}

// MARK: - Output Event

enum SignInOutputEvent {
    case signedIn
    case back
}

// MARK: - View Event

enum SignInViewEvent {
    case viewDidLoad
    case signInTapped
    case `deinit`
}
