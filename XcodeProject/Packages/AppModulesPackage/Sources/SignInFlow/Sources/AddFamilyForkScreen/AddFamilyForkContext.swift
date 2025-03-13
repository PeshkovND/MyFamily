//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct AddFamilyForkContext {
    private init() {}
}

// MARK: - Screen Error

extension AddFamilyForkContext {

    typealias ScreenError = BaseUIError<String>
}

enum AddFamilyForkViewState: Stubable {
    case initial

    static var stub: AddFamilyForkViewState { .initial }
}


// MARK: - Output Event

enum AddFamilyForkOutputEvent {
    case openAddNewFamilyScreen
    case openEnterExistingFamilyScreen
    case logOut
}

// MARK: - View Event

enum AddFamilyForkViewEvent {
    case addNewFamilyTapped
    case enterExistingFamilyTapped
    case logOutTapped
}
