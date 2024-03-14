import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct PostContext {
    private init() {}
}

// MARK: - Screen Error

extension PostContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum PostViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case loaded
    case failed

    static var stub: PostViewState { .initial }
}

// MARK: - Output Event

enum PostOutputEvent {
    case personCardTapped(id: String)
    case shareTapped(id: String)
}

// MARK: - View Event

enum PostViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
    case profileTapped(id: String)
    case shareTapped(id: String)
}
