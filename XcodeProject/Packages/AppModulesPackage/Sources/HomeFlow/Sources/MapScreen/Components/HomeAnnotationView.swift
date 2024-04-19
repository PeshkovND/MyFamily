import MapKit
import AppDesignSystem
import Utilities

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
        imageView.image = appDesignSystem.icons.houseInCircle
        imageView.backgroundColor = .white
        return imageView
    }()
    
    let counterLabel: UILabel = {
        var letterLabel = UILabel(frame: CGRect(x: 25, y: -3, width: 16, height: 16))
        letterLabel.layer.cornerRadius = 8
        letterLabel.textAlignment = .center
        letterLabel.textColor = .white
        letterLabel.layer.backgroundColor = UIColor.red.cgColor
        letterLabel.font = appDesignSystem.typography.body.withSize(10)
        return letterLabel
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clipsToBounds = false
        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        addSubview(imageView)
        displayPriority = .required
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        stackView.removeAllArrangedSubviews()
        if !persons.isEmpty {
            persons.forEach { elem in
                let label = UILabel()
                label.text = elem.name
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
                imageView.layer.cornerRadius = 18.0
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                
                imageView.setImageUrl(url: elem.userImageURL)
                imageView.snp.makeConstraints {
                    $0.width.equalTo(36)
                    $0.height.equalTo(36)
                }
                
                let stack = UIStackView()
                stack.axis = .horizontal
                stack.spacing = 8
                
                stack.addArrangedSubview(imageView)
                stack.addArrangedSubview(label)
                
                stackView.addArrangedSubview(stack)
            }
            
            if !persons.isEmpty {
                addSubview(counterLabel)
                counterLabel.text = String(persons.count)
            } else {
                counterLabel.removeFromSuperview()
            }
            
            detailCalloutAccessoryView = stackView
            canShowCallout = true
        }
    }
}
