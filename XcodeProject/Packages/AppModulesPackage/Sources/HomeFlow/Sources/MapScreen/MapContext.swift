import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit
import CoreLocation

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
    case zoomedTo(location: CLLocationCoordinate2D)
    case currentUserLocationLoaded
    case failed(error: MapContext.ScreenError?)

    static var stub: MapViewState { .initial }
}

// MARK: - Output Event

enum MapOutputEvent { }

// MARK: - View Event

enum MapViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
    case homeTapped
    case userTapped(at: Int)
    case currentUserTapped
}
