import Foundation
import UIKit

public extension UIViewController {
    func withNavigation(tintColor: UIColor) -> UINavigationController {
        let nvc = UINavigationController(rootViewController: self)
        nvc.navigationBar.tintColor = tintColor
        return nvc
    }
}
