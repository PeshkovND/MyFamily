import MapKit
import AppDesignSystem

class MapHomeAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let persons: [MapViewData]
    
    init(
        coordinate: CLLocationCoordinate2D,
        persons: [MapViewData]
    ) {
        self.coordinate = coordinate
        self.persons = persons
    }
}

class MapHomeAnnotationView: MKAnnotationView {
    static let reuseId = "home"
    var persons: [MapViewData] = []
    override var annotation: MKAnnotation? {
        didSet {
            if let ann = annotation as? MapHomeAnnotation {
                self.persons = ann.persons
            }
        }
    }

    let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        imageView.layer.cornerRadius = 18.0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "house.circle.fill")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        )
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        
        return view
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        addSubview(imageView)
       
        displayPriority = .required
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if !persons.isEmpty {
            persons.forEach { elem in
                let label = UILabel()
                label.text = elem.name
                stackView.addArrangedSubview(label)
            }
            detailCalloutAccessoryView = stackView
            canShowCallout = true
        }
    }
}
