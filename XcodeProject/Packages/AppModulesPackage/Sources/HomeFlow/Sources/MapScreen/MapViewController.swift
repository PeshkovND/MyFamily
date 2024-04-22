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
    let isPro: Bool
}

final class MapViewController: BaseViewController<MapViewModel,
                               MapViewEvent,
                               MapViewState,
                               MapViewController.ContentView> {
    
    private let colors = appDesignSystem.colors
    private var mapView: MKMapView { contentView.mapView }
    private var activityIndicator: UIActivityIndicatorView { contentView.activityIndicator }
    private var failedStackView: UIStackView { contentView.failedStackView }
    private var tableView: UITableView { contentView.tableView }
    private var meButton: ActionButton { contentView.meButton }
    private var homeButton: ActionButton { contentView.homeButton }
    
    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    
    deinit {
        viewModel.onViewEvent(.deinit)
    }
    
    private var needFocusOnUser: Bool = true
    
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
    }
    
    override func onViewState(_ viewState: MapViewState) {
        switch viewState {
        case .loaded:
            onDataLoaded()
            failedStackView.alpha = 0
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            showContent()
        case .loading:
            homeButton.alpha = 0
            meButton.alpha = 0
        case .failed:
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
            failedStackView.alpha = 1
        case .initial:
            break
        case .currentUserLocationLoaded:
            self.meButton.alpha = 1
            self.mapView.showsUserLocation = true
        case .zoomedTo(location: let location):
            let region = MKCoordinateRegion(
                center: location,
                latitudinalMeters: self.viewModel.mapDefaultZoom,
                longitudinalMeters: self.viewModel.mapDefaultZoom
            )
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    private func onDataLoaded() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    private func showContent() {
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
    }
    
    private func zoomToHome() {
        guard let coordinate = self.viewModel.homeCoordinate else { return }
        
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
    }
    
    private func configureView() {
        meButton.onTap = { self.viewModel.onViewEvent(.currentUserTapped) }
        homeButton.onTap = { self.viewModel.onViewEvent(.homeTapped) }
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.onViewEvent(.pullToRefresh)
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
            status: person.status,
            isPro: person.isPro
        )
        cell.setup(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onViewEvent(.userTapped(at: indexPath.row))
    }
}

extension MapViewController: UITableViewDelegate { }
