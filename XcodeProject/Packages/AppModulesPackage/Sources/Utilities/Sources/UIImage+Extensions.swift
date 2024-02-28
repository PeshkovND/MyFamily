//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

extension UIImage {

    public static func from(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIImage.imageFromCurrentContext()
        UIGraphicsEndImageContext()

        return image
    }

    private static func imageFromCurrentContext() -> UIImage {
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure(#function + ": cannot get image from current context")
            return UIImage()
        }
        return image
    }
}
