import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct AddPostContext {
    private init() {}
}

// MARK: - Screen Error

extension AddPostContext {

    typealias ScreenError = BaseUIError<String>
}

// MARK: - View State

enum AddPostViewState: Stubable {

    struct ValidatingState {
        let inputError: String?
        let actionEnabled: Bool
    }

    case initial
    case contentLoading
    case contentLoaded
    case contentLoadingError
    case audioRecording
    case audioRecorded
    case loading
    case error

    static var stub: AddPostViewState { .initial }
}

// MARK: - Output Event

enum AddPostOutputEvent {
    case finish(isPostAdded: Bool)
}

// MARK: - View Event

enum AddPostViewEvent {
    case viewDidLoad
    case `deinit`
    case addPostTapped
    case recordAudioDidTapped
    case deleteContentDidTapped
    case backTapped
    case mediaChoosed(data: Data, contentType: ContentType)
}
