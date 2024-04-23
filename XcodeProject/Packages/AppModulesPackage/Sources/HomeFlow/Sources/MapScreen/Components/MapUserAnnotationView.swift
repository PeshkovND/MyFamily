import MapKit
import AppDesignSystem
import AppEntities

final class MapQuickEventUserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let photo: URL?
    let title: String?
    let status: PersonStatus
    
    init(
        coordinate: CLLocationCoordinate2D,
        photo: URL?,
        title: String,
        status: PersonStatus
    ) {
        self.coordinate = coordinate
        self.photo = photo
        self.title = title
        self.status = status
    }
}

final class MapUserAnnotationView: MKAnnotationView {
    static let reuseId = "quickEventUser"
    var photo: URL?
    var status: PersonStatus?
    var title: String?
    override var annotation: MKAnnotation? {
        didSet {
            if let ann = annotation as? MapQuickEventUserAnnotation {
                self.photo = ann.photo
                self.title = ann.title
                self.status = ann.status
            }
        }
    }

    let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        imageView.layer.cornerRadius = 18.0
        imageView.layer.borderWidth = 3.0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        addSubview(imageView)
        canShowCallout = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let photoURL = photo {
            let url = photoURL
            imageView.setImageUrl(url: url)
        } else {
            imageView.image = nil
        }
        switch status {
        case .offline:
            imageView.layer.borderColor = UIColor.gray.cgColor
        case .online:
            imageView.layer.borderColor = appDesignSystem.colors.backgroundSecondaryVariant.cgColor
        case .atHome:
            imageView.layer.borderColor = appDesignSystem.colors.backgroundSecondaryVariant.cgColor
        case .none:
            break
        }
    }
}
