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
    case fullscreenLoading
    case failed(error: ProfileContext.ScreenError?)
    case alert(title: String, subtitle: String)

    static var stub: ProfileViewState { .initial }
}

// MARK: - Output Event

enum ProfileOutputEvent {
    case commentTapped(id: String)
    case shareTapped(id: String)
    case signOut
    case editProfile
    case getPro
    case deleteFamily
}

// MARK: - View Event

enum ProfileViewEvent {
    case viewDidLoad
    case `deinit`
    case pullToRefresh
    case commentTapped(id: String)
    case shareTapped(id: String)
    case signOut
    case getProTapped
    case editProfileTapped
    case leaveFamilyTapped
}
