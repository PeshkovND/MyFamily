import UIKit
import CoreLocation
import AppEntities
import AppDesignSystem
import AppBaseFlow
import MapKit

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

struct MapViewData {
    let id: Int
    let userImageURL: URL?
    let name: String
    let status: PersonStatus
    let coordinate: Coordinate
}

final class MapViewController: BaseViewController<MapViewModel,
                                MapViewEvent,
                                MapViewState,
                                MapViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    
    private let locationManager = CLLocationManager()
    private let mapDefaultZoom = 1000.0
    private var mapView: MKMapView { contentView.mapView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var tableView: UITableView { contentView.tableView }
    private var meButton: ActionButton { contentView.meButton }
    private var homeButton: ActionButton { contentView.homeButton }
    
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
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.isNavigationBarHidden = true
        configureView()
        viewModel.onViewEvent(.viewDidLoad)
        mapView.delegate = self
        navigationController?.navigationBar.backgroundColor = colors.backgroundPrimary
        tabBarController?.tabBar.backgroundColor = colors.backgroundPrimary
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationEnabled()
        checkAuthorization()
    }

    override func onViewState(_ viewState: MapViewState) {
        switch viewState {
        case .loaded:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            tableView.reloadData()
            viewModel.personsNotAtHome.forEach { elem in
                let annotation = MapQuickEventUserAnnotation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: elem.coordinate.latitude,
                        longitude: elem.coordinate.longitude
                    ),
                    photo: elem.userImageURL,
                    title: elem.name,
                    status: elem.status
                )
                
                mapView.addAnnotation(annotation)
            }
            
            guard let coordinate = viewModel.homeCoordinate else { return }
            
            let annotation = MapHomeAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                persons: viewModel.personsAtHome
            )
            homeButton.alpha = 1
            mapView.addAnnotation(annotation)
        case .loading:
            homeButton.alpha = 0
            meButton.alpha = 0
        default:
            break
        }
    }
    
    private func configureView() {
        meButton.onTap = zoomToCurrentUser
        homeButton.onTap = zoomToHome
        tableView.refreshControl = refreshControl
    }
    
    private func zoomToHome() {
        guard let coordinate = self.viewModel.homeCoordinate else { return }
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            latitudinalMeters: self.mapDefaultZoom,
            longitudinalMeters: self.mapDefaultZoom
        )
        self.mapView.setRegion(region, animated: true)
    }
    
    private func zoomToCurrentUser() {
        if let location = self.locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: self.mapDefaultZoom,
                longitudinalMeters: self.mapDefaultZoom
            )
            self.mapView.setRegion(region, animated: true)
        }
    }
    
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
                latitudinalMeters: mapDefaultZoom,
                longitudinalMeters: mapDefaultZoom
            )
            mapView.setRegion(region, animated: true)
            meButton.alpha = 1
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapQuickEventUserAnnotation {
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapUserAnnotationView.reuseId)
            
            guard let annotationView = annotationView as? MapUserAnnotationView else { return nil }
            annotationView.annotation = annotation
            return annotationView
        }
        if let annotation = annotation as? MapHomeAnnotation {
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MapHomeAnnotationView.reuseId)
            
            guard let annotationView = annotationView as? MapHomeAnnotationView else { return nil }
            annotationView.annotation = annotation
            annotationView.layoutIfNeeded()
            return annotationView
        }
        return nil
    }
}

extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: PersonCell.self), for: indexPath)
        guard let cell = cell as? PersonCell else { return cell }
        let person = viewModel.persons[indexPath.row]
        let model = PersonCell.Model(
            userImageURL: person.userImageURL,
            name: person.name,
            status: person.status
        )
        cell.setup(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = viewModel.persons[indexPath.row]
        
        if item.status == .atHome {
            zoomToHome()
            return
        }
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: item.coordinate.latitude,
                longitude: item.coordinate.longitude
            ),
            latitudinalMeters: mapDefaultZoom,
            longitudinalMeters: mapDefaultZoom
        )
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController: UITableViewDelegate { }
