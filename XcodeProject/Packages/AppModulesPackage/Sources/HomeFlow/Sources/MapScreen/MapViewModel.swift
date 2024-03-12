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
    
    var homeCoordinate: Coordinate?
    
    private let strings = appDesignSystem.strings
    private let mockData: [MapViewData] = [
        MapViewData(
            id: "0",
            userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Виталий Громяка",
            status: .atHome,
            coordinate: Coordinate(latitude: 312.78, longitude: -122.40)
        ),
        MapViewData(
            id: "1", userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Иванов Иван",
            status: .offline(lastOnline: "11 march, 11:37"),
            coordinate: Coordinate(latitude: 37.781, longitude: -122.401)
        ),
        MapViewData(
            id: "2",
            userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Генадий Генадиев",
            status: .online,
            coordinate: Coordinate(latitude: 37.783, longitude: -122.403)
        ),
        MapViewData(
            id: "2",
            userImageURL:
                URL(
                    string: "https://tlgrm.ru/_/stickers/50e/b0c/50eb0c04-bbdf-497e-81c4-1130314a75b3/3.png"
                ),
            name: "Генадий Генадиев",
            status: .atHome,
            coordinate: Coordinate(latitude: 37.783, longitude: -122.403)
        ),
    ]
    
    override func onViewEvent(_ event: MapViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            self.viewState = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.persons = self.mockData
                self.homeCoordinate = Coordinate(latitude: 37.78, longitude: -122.40)
                self.viewState = .loaded
            }
            viewState = .initial
        case .pullToRefresh:
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
