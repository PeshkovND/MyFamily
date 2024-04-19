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
            view.register(
                MapUserAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: MapUserAnnotationView.reuseId
            )
            view.register(
                MapHomeAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: MapHomeAnnotationView.reuseId
            )
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
        
        private(set) lazy var homeButton: ActionButton = {
            let button = ActionButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.borderColor = colors.backgroundSecondaryVariant.cgColor
            button.layer.borderWidth = 4
            button.layer.cornerRadius = 20
            button.backgroundColor = colors.backgroundPrimary
            button.setImage(icons.homeFill, for: .normal)
            return button
        }()
        
        private(set) lazy var meButton: ActionButton = {
            let button = ActionButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.borderColor = colors.backgroundSecondaryVariant.cgColor
            button.layer.borderWidth = 4
            button.layer.cornerRadius = 20
            button.backgroundColor = colors.backgroundPrimary
            button.setImage(icons.location, for: .normal)
            return button
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
        
        private(set) lazy var failedStackView: UIStackView = {
            return FailedStackView(
                title: appDesignSystem.strings.contentLoadingErrorTitle,
                subtitle: appDesignSystem.strings.contentLoadingErrorSubitle
            )
        }()
        
        override func setLayout() {
            backgroundColor = colors.backgroundPrimary
            addSubview(mapContainer)
            addSubview(tableView)
            mapContainer.addSubview(mapView)
            mapContainer.addSubview(homeButton)
            mapContainer.addSubview(meButton)
            tableView.addSubview(activityIndicator)
            addSubview(failedStackView)
            
            setupConstraints()
        }
            
        func setupConstraints() {
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
            
            homeButton.snp.makeConstraints {
                $0.height.equalTo(40)
                $0.width.equalTo(40)
                $0.bottom.equalTo(meButton.snp.top).inset(-12)
                $0.trailing.equalToSuperview().inset(8)
            }
            
            meButton.snp.makeConstraints {
                $0.height.equalTo(40)
                $0.width.equalTo(40)
                $0.bottom.equalToSuperview().inset(40)
                $0.trailing.equalToSuperview().inset(8)
            }
            
            failedStackView.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.85)
                $0.center.equalTo(tableView.snp.center)
            }
        }
    }
}
