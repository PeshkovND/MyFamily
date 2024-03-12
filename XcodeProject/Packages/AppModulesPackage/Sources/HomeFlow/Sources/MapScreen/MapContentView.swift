import UIKit
import SnapKit
import AppBaseFlow
import AppDesignSystem
import Utilities
import MapKit

extension MapViewController {

    final class ContentView: BaseView {

        private(set) lazy var mapView: MKMapView = {
            let view = MKMapView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.register(MapUserAnnotationView.self, forAnnotationViewWithReuseIdentifier: MapUserAnnotationView.reuseId)
            return view
        }()
        
        private(set) lazy var tableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.backgroundColor = colors.backgroundPrimary
            tableView.showsVerticalScrollIndicator = false
            tableView.register(PersonCell.self, forCellReuseIdentifier: String(describing: PersonCell.self))
            tableView.separatorStyle = .none
            tableView.layer.cornerRadius = 28
            tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            tableView.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)
            return tableView
        }()
        
        private(set) lazy var mapContainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            return view
        }()
        
        private(set) lazy var activityIndicator: UIActivityIndicatorView = {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = .black
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            return activityIndicator
        }()
        
        override func setLayout() {
            backgroundColor = colors.backgroundPrimary
            addSubview(mapContainer)
            addSubview(tableView)
            mapContainer.addSubview(mapView)
            tableView.addSubview(activityIndicator)
            
            mapContainer.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalTo(tableView.snp.top).inset(28)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            tableView.snp.makeConstraints {
                $0.height.equalToSuperview().multipliedBy(0.35)
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            mapView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            
            activityIndicator.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
    }
}
