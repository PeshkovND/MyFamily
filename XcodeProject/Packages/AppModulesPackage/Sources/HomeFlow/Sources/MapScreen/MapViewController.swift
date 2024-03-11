import UIKit
import CoreLocation
import AppEntities
import AppDesignSystem
import AppBaseFlow
import MapKit

final class MapViewController: BaseViewController<MapViewModel,
                                MapViewEvent,
                                MapViewState,
                                MapViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private let locationManager = CLLocationManager()
    private var mapView: MKMapView { contentView.mapView }
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        refreshControl.tintColor = colors.labelPrimary
        return refreshControl
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
        navigationController?.navigationBar.backgroundColor = colors.backgroundPrimary
        tabBarController?.tabBar.backgroundColor = colors.backgroundPrimary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
        checkAuthorization()
    }
    
    override func onViewState(_ viewState:MapViewState) {
        switch viewState {
        case .loaded:
            break
        default: break
        }
    }
    
    private func configureView() {}
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationEnabled() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.setupLocationManager()
            } else {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Please enable location services",
                    preferredStyle: .alert
                )
                
                self.present(alert, animated: true)
            }
        }
    }
    
    private func checkAuthorization() {
        // swiftlint:disable closure_body_length
            switch self.locationManager.authorizationStatus {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            case .restricted:
                break
            case .denied:
                let alert = UIAlertController(
                    title: "Error",
                    message: "Please enable always-on location",
                    preferredStyle: .alert
                )
                self.present(alert, animated: true)
            case .authorizedAlways:
                self.mapView.showsUserLocation = true
                self.locationManager.startUpdatingLocation()
            case .authorizedWhenInUse:
                self.locationManager.requestAlwaysAuthorization()
            @unknown default:
                break
            }
    }

    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
}
