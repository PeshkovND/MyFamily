import Foundation
import AppEntities
import AppServices
import AppBaseFlow
import AVKit

// MARK: - Context

struct FamilyInvitationContext {
    private init() {}
}

// MARK: - Screen Error

extension FamilyInvitationContext {

    typealias ScreenError = BaseUIError<String>
}

struct FamilyInvitationViewData {
    let id: String
    let dateCreated: String
}

// MARK: - View State

enum FamilyInvitationViewState: Stubable {
    case initial
    case loading
    case loaded(content: [FamilyInvitationViewData])
    case failed(error: FamilyInvitationContext.ScreenError?)
    case alert(title: String, subtitle: String)

    static var stub: FamilyInvitationViewState { .initial }
}

// MARK: - Output Event

enum FamilyInvitationOutputEvent {
    case onBack
}

// MARK: - View Event

enum FamilyInvitationViewEvent {
    case viewDidAppear
    case addCodeTapped
    case pullToRefresh
    case deleteCodeTapped(id: String)
    case copyCodeTapped(id: String)
    case backTapped
}
