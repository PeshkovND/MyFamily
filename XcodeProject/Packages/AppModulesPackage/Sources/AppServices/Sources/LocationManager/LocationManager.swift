import Foundation
import CoreLocation
import Combine

public enum AppLocationManagerEvent {
    case locationServicesNotEnabled
    case checkAuthorizationFailed
    case didUpdateLocation(location: CLLocationCoordinate2D)
    case observationStarted
}

public final class AppLocationManager: NSObject {
    private let locationManager = CLLocationManager()
    public var lastLocation: CLLocationCoordinate2D?
    
    public var outputEventPublisher: AnyPublisher<AppLocationManagerEvent, Never> {
        outputEventSubject.eraseToAnyPublisher()
    }

    public var outputEventSubject: PassthroughSubject<AppLocationManagerEvent, Never> = .init()
    
    public override init() {
        super.init()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    private func checkLocationEnabled() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                self.outputEventSubject.send(.locationServicesNotEnabled)
            }
        }
    }
    
    public func setup() {
        checkLocationEnabled()
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        // swiftlint:disable closure_body_length
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            case .restricted:
                self.outputEventSubject.send(.checkAuthorizationFailed)
            case .denied:
                self.outputEventSubject.send(.checkAuthorizationFailed)
            case .authorizedAlways:
                self.locationManager.startUpdatingLocation()
                self.lastLocation = locationManager.location?.coordinate
                self.outputEventSubject.send(.observationStarted)
            case .authorizedWhenInUse:
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
                self.lastLocation = locationManager.location?.coordinate
                self.outputEventSubject.send(.observationStarted)
            @unknown default:
                break
            }
    }
}

extension AppLocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last?.coordinate {
                lastLocation = location
                self.outputEventSubject.send(.didUpdateLocation(location: location))
            }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
}
