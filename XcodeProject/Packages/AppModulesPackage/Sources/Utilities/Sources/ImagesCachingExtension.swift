import Foundation
import UIKit
import Kingfisher

public extension UIImageView {
    func setImageUrl(url: URL?, complition: ((UIImage) -> Void)? = nil) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                         options: [.cacheOriginalImage]) { result in
            switch result {
            case .success(let value):
                self.image = value.image
                complition?(value.image)
            case .failure:
                self.image = UIImage(named: "error")
            }
        }
    }
}
