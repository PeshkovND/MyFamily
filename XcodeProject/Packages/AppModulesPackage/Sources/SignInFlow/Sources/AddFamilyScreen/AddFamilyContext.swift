//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct AddFamilyContext {
    private init() {}
}

// MARK: - Screen Error

extension AddFamilyContext {
    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum AddFamilyViewState: Stubable {

    case initial
    case loading
    case error(title: String, subtitle: String)
    case addressConfirmation(address: String)

    static var stub: AddFamilyViewState { .initial }
}

// MARK: - Output Event

enum AddFamilyOutputEvent {
    case familyCreated
    case back
}

// MARK: - View Event

enum AddFamilyViewEvent {
    case viewDidLoad
    case addressConfirmed(name: String)
    case addFamilyTapped(address: String)
    case backButtonTapped
}
