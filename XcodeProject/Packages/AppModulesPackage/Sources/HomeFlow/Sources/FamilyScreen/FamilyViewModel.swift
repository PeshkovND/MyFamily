import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class FamilyViewModel: BaseViewModel<FamilyViewEvent,
                                               FamilyViewState,
                                               FamilyOutputEvent> {
    
    private let strings = appDesignSystem.strings
    private let repository: FamilyRepository
    var persons: [FamilyViewData] = []
    
    init(repository: FamilyRepository) {
        self.repository = repository
    }
    
    override func onViewEvent(_ event: FamilyViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            self.viewState = .loading
            getUsers()
        case .pullToRefresh:
            self.viewState = .loading
            getUsers()
        case .profileTapped(id: let id):
            outputEventSubject.send(.personCardTapped(id: id))
        }
    }
    
    private func getUsers() {
        Task {
            do {
                self.persons = try await repository.getUsers()
                await MainActor.run {
                    self.viewState = .loaded(content: persons)
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
