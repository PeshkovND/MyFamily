//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct JoinFamilyContext {
    private init() {}
}

// MARK: - Screen Error

extension JoinFamilyContext {
    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum JoinFamilyViewState: Stubable {

    case initial
    case loading
    case error(title: String, subtitle: String)

    static var stub: JoinFamilyViewState { .initial }
}

// MARK: - Output Event

enum JoinFamilyOutputEvent {
    case familyJoined
    case back
}

// MARK: - View Event

enum JoinFamilyViewEvent {
    case joinFamilyTapped(code: String)
    case backButtonTapped
}
