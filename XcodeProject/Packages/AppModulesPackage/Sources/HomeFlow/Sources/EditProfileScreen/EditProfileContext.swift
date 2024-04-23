import Foundation
import AppEntities
import AppServices
import AppBaseFlow

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

    case initial(firstname: String, lastname: String, photoUrl: URL? )
    case imageloading(data: Data)
    case imageLoaded
    case contentLoadingError
    case loading
    case failure

    static var stub: EditProfileViewState { .initial(
        firstname: "",
        lastname: "",
        photoUrl: nil
    ) }
}

// MARK: - Output Event

enum EditProfileOutputEvent {
    case saveTapped
    case onBack
}

// MARK: - View Event

enum EditProfileViewEvent {
    case viewDidLoad
    case `deinit`
    case saveButtonDidTapped
    case onBack
    case usernameDidChanged(firstname: String, lastName: String)
    case photoChoosed(data: Data)
}
