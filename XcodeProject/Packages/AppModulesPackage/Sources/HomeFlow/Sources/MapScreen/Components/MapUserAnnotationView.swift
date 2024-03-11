import MapKit
import AppDesignSystem

class MapQuickEventUserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let photo: String
    
    init(coordinate: CLLocationCoordinate2D, photo: String) {
        self.coordinate = coordinate
        self.photo = photo
    }
}

class MapUserAnnotationView: MKAnnotationView {
    static let reuseId = "quickEventUser"
    var photo: String?
    override var annotation: MKAnnotation? {
        didSet {
            if let ann = annotation as? MapQuickEventUserAnnotation {
                self.photo = ann.photo
            }
        }
    }

    let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.layer.cornerRadius = 25.0
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = appDesignSystem.colors.backgroundSecondaryVariant.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let photoURL = photo {
            let url = URL(string: photoURL)
            imageView.setImageUrl(url: url)
        } else {
            imageView.image = nil
        }
    }
}
