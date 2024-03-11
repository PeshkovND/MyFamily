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
            mapContainer.addSubview(mapView)
            
            mapContainer.snp.makeConstraints{
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
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
        }
    }
}
