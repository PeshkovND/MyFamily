import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class FamilyInvitationViewModel: BaseViewModel<FamilyInvitationViewEvent,
                                               FamilyInvitationViewState,
                                               FamilyInvitationOutputEvent> {
    
    private let strings = appDesignSystem.strings
    private let repository: FamilyInvitationRepository
    var invitations: [FamilyInvitationViewData] = []
    
    init(repository: FamilyInvitationRepository) {
        self.repository = repository
    }
    
    override func onViewEvent(_ event: FamilyInvitationViewEvent) {
        switch event {
        case .viewDidAppear:
            self.viewState = .loading
            getInvitations()
        case .addCodeTapped:
            self.viewState = .loading
            addInvitations()
        case .deleteCodeTapped(let id):
            self.viewState = .loading
            deleteInvitation(id: id)
        case .copyCodeTapped(let id):
            UIPasteboard.general.string = id
        case .pullToRefresh:
            getInvitations()
        case .backTapped:
            outputEventSubject.send(.onBack)
        }
    }
    
    private func getInvitations() {
        Task {
            do {
                self.invitations = try await repository.getInvitations()
                await MainActor.run {
                    self.viewState = .loaded(content: invitations)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .failed(
                        error: self.makeScreenError(
                            from: .custom(
                                title: self.strings.contentLoadingErrorTitle,
                                message: self.strings.contentLoadingErrorSubitle
                            )
                        )
                    )
                }
            }
        }
    }
    
    private func addInvitations() {
        Task {
            do {
                let invitation = try await repository.addInvitation()
                self.invitations.append(invitation)
                await MainActor.run {
                    self.viewState = .loaded(content: invitations)
                }
            } catch let e {
                if let error = e as? FirebaseClientError {
                    switch error {
                    case .parsingError, .fetchingError:
                        await MainActor.run {
                            self.viewState = .alert(
                                title: "Failed to add new invitation code",
                                subtitle: "Please check your internet connection"
                            )
                        }
                    case .documentAlreadyExists:
                        addInvitations()
                    }
                } else {
                    await MainActor.run {
                        self.viewState = .alert(
                            title: "Failed to add new invitation code",
                            subtitle: "Please check your internet connection"
                        )
                    }
                }
            }
        }
    }
    
    private func deleteInvitation(id: String) {
        Task {
            do {
                try await repository.deleteInvitation(id: id)
                invitations = invitations.filter { $0.id != id }
                await MainActor.run {
                    self.viewState = .loaded(content: invitations)
                }
            } catch {
                await MainActor.run {
                    self.viewState = .alert(
                        title: "Failed to delete invitation code",
                        subtitle: "Please check your internet connection"
                    )
                }
            }
        }
    }
    
    private func makeScreenError(from appError: AppError) -> NewsContext.ScreenError? {
        switch appError {
        case .api(general: let generalError, specific: let specificErrors):
            switch generalError.code {
            default:
                let screenError: NewsContext.ScreenError = .init(
                    alert: .init(title: strings.commonError, message: generalError.message),
                    fieldsInfo: specificErrors
                        .first?.message
                )
                return screenError
            }
        case .network:
            let screenError: NewsContext.ScreenError = .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork),
                fieldsInfo: nil
            )
            return screenError
        default:
            return NewsContext.ScreenError.defaultUIError(from: appError)
        }
    }
}
