import Foundation
import UIKit
import SwiftMessages

public class AppSnackBar {
    
    private let config: SwiftMessages.Config = {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.prefersStatusBarHidden = true
        config.interactiveHide = true
        config.haptic = .success
        return config
    }()
    
    private let snackbar: MessageView = {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return view
    }()
    
    @MainActor
    public func showIn(view: UIView) {
        SwiftMessages.show(config: config) {
            self.snackbar
        }
    }
    
    public init(text: String) {
        snackbar.configureContent(body: text)
    }
}
