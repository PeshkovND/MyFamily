//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import JGProgressHUD

// INFO: This helper is considered to use for temporarily soluton
// Until visual design are not provided for loading state

public final class LoadingViewHelper {

    private let hud = JGProgressHUD()

    init() {}

    public func showLoadingViw(in view: UIView, message: String) {
        hud.textLabel.text = message
        hud.style = .dark
        hud.show(in: view)
    }

    public func dismissLoadingView() {
        hud.dismiss()
    }
}
