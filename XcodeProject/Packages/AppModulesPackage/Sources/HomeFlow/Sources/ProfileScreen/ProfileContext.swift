import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct ProfileContext {
    private init() {}
}

// MARK: - Screen Error

extension ProfileContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum ProfileViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case loaded
    case failed(error: ProfileContext.ScreenError)

    static var stub: ProfileViewState { .initial }
}

// MARK: - Output Event

enum ProfileOutputEvent { }

// MARK: - View Event

enum ProfileViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
}
