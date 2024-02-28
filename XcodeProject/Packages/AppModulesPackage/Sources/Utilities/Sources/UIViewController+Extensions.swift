//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: - Alerts & ActionSheet

extension UIViewController {

    public static func actionSheet(title: String? = nil, message: String? = nil, actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet
        )
        actions.forEach(alertController.addAction(_:))
        return alertController
    }

    public static func alert(title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        actions.forEach(alertController.addAction(_:))
        return alertController
    }
}
