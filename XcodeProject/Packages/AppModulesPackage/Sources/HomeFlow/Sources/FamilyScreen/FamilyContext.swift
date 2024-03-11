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
    case loaded(content: [FamilyViewData])
    case failed(error: FamilyContext.ScreenError)

    static var stub: FamilyViewState { .initial }
}

// MARK: - Output Event

enum FamilyOutputEvent {
    case personCardTapped(id: String)
}

// MARK: - View Event

enum FamilyViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
}
