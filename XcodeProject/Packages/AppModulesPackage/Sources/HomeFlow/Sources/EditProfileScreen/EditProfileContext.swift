import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct EditProfileContext {
    private init() {}
}

// MARK: - Screen Error

extension EditProfileContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum EditProfileViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case imageloading
    case imageLoaded
    case contentLoadingError

    static var stub: EditProfileViewState { .initial }
}

// MARK: - Output Event

enum EditProfileOutputEvent {
    case addedPost
}

// MARK: - View Event

enum EditProfileViewEvent {
    case viewDidLoad
    case `deinit`
}
