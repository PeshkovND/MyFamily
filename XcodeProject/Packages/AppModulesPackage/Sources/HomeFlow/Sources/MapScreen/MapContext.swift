import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct MapContext {
    private init() {}
}

// MARK: - Screen Error

extension MapContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum MapViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case loading
    case loaded
    case failed(error: MapContext.ScreenError)

    static var stub: MapViewState { .initial }
}

// MARK: - Output Event

enum MapOutputEvent { }

// MARK: - View Event

enum MapViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
}
