//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - View State

enum WelcomeViewState: Stubable {

    case initial

    static var stub: WelcomeViewState { .initial }
}

// MARK: - Output Event

enum WelcomeOutputEvent {
    case `continue`
}

// MARK: - View Event

enum WelcomeViewEvent {
    case actionSignIn
}
