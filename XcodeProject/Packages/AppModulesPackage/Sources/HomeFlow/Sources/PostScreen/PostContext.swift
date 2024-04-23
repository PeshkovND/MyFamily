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
    case addCommentLoading
    case addCommentFailed

    static var stub: PostViewState { .initial }
}

// MARK: - Output Event

enum PostOutputEvent {
    case personCardTapped(id: Int)
    case shareTapped(id: String)
}

// MARK: - View Event

enum PostViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
    case profileTapped(id: Int)
    case shareTapped(id: String)
    case addCommentTapped(text: String, onSucces: () -> Void)
}
