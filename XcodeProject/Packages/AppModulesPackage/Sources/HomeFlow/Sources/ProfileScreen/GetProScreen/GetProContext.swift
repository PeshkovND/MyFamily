import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct GetProContext {
    private init() {}
}

// MARK: - Screen Error

extension GetProContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum GetProViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case loaded
    case alreadyBuyed
    case failed

    static var stub: GetProViewState { .initial }
}

// MARK: - Output Event

enum GetProOutputEvent {
    case finish(isSuccess: Bool)
}

// MARK: - View Event

enum GetProViewEvent {
    case viewDidLoad
    case `deinit`
    case buyTapped
}
