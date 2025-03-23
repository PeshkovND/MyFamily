import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct FamilyContext {
    private init() {}
}

// MARK: - Screen Error

extension FamilyContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum FamilyViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case fullscreenLoading
    case loaded(content: [FamilyViewData])
    case failed(error: FamilyContext.ScreenError?)
    case alert(title: String, subtitle: String)
    case deleteConfirmation(FamilyViewData)

    static var stub: FamilyViewState { .initial }
}

// MARK: - Output Event

enum FamilyOutputEvent {
    case personCardTapped(id: Int)
    case addUserTapped
}

// MARK: - View Event

enum FamilyViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
    case profileTapped(id: Int)
    case addUserTapped
    case deleteUserTapped(id: Int)
    case deleteUserConfirmationTapped(user: FamilyViewData)
}
