//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct FamilyCheckingContext {
    private init() {}
}

// MARK: - Screen Error

extension FamilyCheckingContext {
    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum FamilyCheckingViewState: Stubable {

    case loading
    case error(title: String, subtitle: String)

    static var stub: FamilyCheckingViewState { .loading }
}

// MARK: - Output Event

enum FamilyCheckingOutputEvent {
    case familyFound
    case familyNotFound
}

// MARK: - View Event

enum FamilyCheckingViewEvent {
    case viewDidAppear
    case retryButtonTapped
}
