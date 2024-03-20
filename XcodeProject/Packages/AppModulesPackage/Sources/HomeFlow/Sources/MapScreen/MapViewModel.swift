import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

final class MapViewModel: BaseViewModel<MapViewEvent,
                                               MapViewState,
                                               MapOutputEvent> {
    
    var persons: [MapViewData] = []
    var personsAtHome: [MapViewData] { persons.filter { $0.status == .atHome } }
    var personsNotAtHome: [MapViewData] { persons.filter { $0.status != .atHome } }
    private let repository: MapRepository
    
    init(repository: MapRepository) {
        self.repository = repository
    }
    
    var homeCoordinate: Coordinate?
    
    private let strings = appDesignSystem.strings
    
    override func onViewEvent(_ event: MapViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            self.viewState = .loading
            getUsers()
            viewState = .initial
        case .pullToRefresh:
            getUsers()
        }
    }
    
    private func getUsers() {
        Task {
            self.persons = try await self.repository.getUsers()
            self.homeCoordinate = self.repository.getHomePosition()
            await MainActor.run {
                self.viewState = .loaded
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
