//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import IQKeyboardManagerSwift

/// It allows to prevent issues of keyboard sliding up and cover `UITextField/UITextView`.
/// It's usually used for screens with input fields

public protocol KeyboardAutoManaging: UIViewController {
    func enableKeyboardHander()
    func disableKeyboardHander()
}

extension KeyboardAutoManaging {

    private var keyboardManager: IQKeyboardManager { .shared } // swiftlint:disable:this explicit_singleton

    public func enableKeyboardHander() {
        keyboardManager.enable = true
        keyboardManager.enableAutoToolbar = true
    }

    public func disableKeyboardHander() {
        keyboardManager.enable = false
        keyboardManager.enableAutoToolbar = false
    }
}

public struct KeyboardHealper {

    public static func firstEnableKeyboardManager() {
        IQKeyboardManager.shared.enable = true // swiftlint:disable:this explicit_singleton
    }

    private init() {}
}
