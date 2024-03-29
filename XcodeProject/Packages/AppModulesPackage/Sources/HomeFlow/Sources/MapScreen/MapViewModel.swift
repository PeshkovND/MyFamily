import UIKit
import AVFoundation
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import CoreLocation

final class MapViewModel: BaseViewModel<MapViewEvent,
                          MapViewState,
                          MapOutputEvent> {
    
    let mapDefaultZoom = 1000.0
    var persons: [MapViewData] = []
    var personsAtHome: [MapViewData] { persons.filter { $0.status == .atHome } }
    var personsNotAtHome: [MapViewData] { persons.filter { $0.status != .atHome } }
    private let repository: MapRepository
    private let locationManager: AppLocationManager
    private var needZoomToCurrentUser = true
    private var setCancelable = Set<AnyCancellable>()
    
    init(repository: MapRepository, locationManager: AppLocationManager) {
        self.repository = repository
        self.locationManager = locationManager
    }
    
    var homeCoordinate: Coordinate?
    
    private let strings = appDesignSystem.strings
    
    override func onViewEvent(_ event: MapViewEvent) {
        switch event {
        case .deinit:
            break
        case .viewDidLoad:
            
            locationManager.outputEventPublisher.sink { event in
                switch event {
                case .didUpdateLocation(location: let location):
                    if self.needZoomToCurrentUser { self.currentUserLocationLoaded(location: location) }
                case .locationServicesNotEnabled:
                    break
                case .checkAuthorizationFailed:
                    break
                case .observationStarted:
                    break
                }
            }.store(in: &setCancelable)
            
            self.viewState = .loading
            getUsers()
            viewState = .initial
            
            if let location = locationManager.lastLocation, self.needZoomToCurrentUser { currentUserLocationLoaded(location: location) }
        case .pullToRefresh:
            getUsers()
        case .homeTapped:
            zoomToHome()
        case .userTapped(at: let index):
            zoomToUser(index: index)
        case .currentUserTapped:
            zoomToCurrentUser()
        }
    }
    
    private func currentUserLocationLoaded(location: CLLocationCoordinate2D) {
        self.viewState = .currentUserLocationLoaded
        self.viewState = .zoomedTo(location: location)
        self.needZoomToCurrentUser = false
    }
    
    private func zoomToHome() {
        guard let coordinate = self.homeCoordinate else { return }
        let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        viewState = .zoomedTo(location: location)
    }
    
    private func zoomToUser(index: Int) {
        let item = persons[index]
        
        if item.status == .atHome {
            zoomToHome()
            return
        }
        viewState = .zoomedTo(location: CLLocationCoordinate2D(
            latitude: item.coordinate.latitude,
            longitude: item.coordinate.longitude
        ))
    }
    
    private func zoomToCurrentUser() {
        guard let location = locationManager.lastLocation else { return }
        viewState = .zoomedTo(location: location)
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
