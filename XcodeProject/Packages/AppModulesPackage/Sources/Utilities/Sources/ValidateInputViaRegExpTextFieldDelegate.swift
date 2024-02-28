//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public final class ValidateInputViaRegExpTextFieldDelegate: NSObject, UITextFieldDelegate {

    private var pattern: String

    public init(pattern: String) {
        self.pattern = pattern

        super.init()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isNotEmpty else { return true }

        return string.matchesRegExp(pattern: pattern)
    }
}
