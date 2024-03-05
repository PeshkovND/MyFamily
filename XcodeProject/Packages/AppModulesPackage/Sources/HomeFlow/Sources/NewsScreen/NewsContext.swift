import Foundation
import AppEntities
import AppServices
import AppBaseFlow

// MARK: - Context

struct NewsContext {
    private init() {}
}

// MARK: - Screen Error

extension NewsContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum NewsViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case loaded(content: [NewsViewPost])
    case failed(error: NewsContext.ScreenError)

    static var stub: NewsViewState { .initial }
}

// MARK: - Output Event

enum NewsOutputEvent {
    case addPost
}

// MARK: - View Event

enum NewsViewEvent {
    case viewDidLoad
    case `deinit`
    case addPostTapped
    case pullToRefresh
}
