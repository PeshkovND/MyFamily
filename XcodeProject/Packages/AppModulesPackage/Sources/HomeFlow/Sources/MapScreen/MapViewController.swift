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
        configureButtons()
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func onViewState(_ viewState: MapViewState) {
        switch viewState {
        case .loaded:
            hideLoading()
            failedStackView.alpha = 0
            showContent()
        case .loading:
            homeButton.alpha = 0
            meButton.alpha = 0
        case .failed:
            hideLoading()
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
    
    private func hideLoading() {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
    }
    
    private func showContent() {
        tableView.reloadData()
        mapView.removeAnnotations(mapView.annotations)
        setUsersAnnotations()
        setHomeAnnotation()
        homeButton.alpha = 1
    }
    
    private func setUsersAnnotations() {
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
    }
    
    private func setHomeAnnotation() {
        guard let coordinate = viewModel.homeCoordinate else { return }
        
        let annotation = MapHomeAnnotation(
            coordinate: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            persons: viewModel.personsAtHome
        )
        mapView.addAnnotation(annotation)
    }
    
    private func configureView() {
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.isNavigationBarHidden = true
        mapView.delegate = self
        navigationController?.navigationBar.backgroundColor = colors.backgroundPrimary
        tabBarController?.tabBar.backgroundColor = colors.backgroundPrimary
    }
    
    private func configureButtons() {
        meButton.onTap = { self.viewModel.onViewEvent(.currentUserTapped) }
        homeButton.onTap = { self.viewModel.onViewEvent(.homeTapped) }
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
}

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onViewEvent(.userTapped(at: indexPath.row))
    }
}
