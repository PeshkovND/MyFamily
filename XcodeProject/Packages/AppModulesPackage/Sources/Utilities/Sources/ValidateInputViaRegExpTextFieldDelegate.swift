//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public final class ValidateInputViaRegExpTextFieldDelegate: NSObject, UITextFieldDelegate {

    private var pattern: String

    public init(pattern: String) {
        self.pattern = pattern

        super.init()
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let replacementRange = Range(range, in: currentText) else {
            return false
        }

        let proposedText = currentText.replacingCharacters(
            in: replacementRange,
            with: string
        )

        guard !proposedText.isEmpty else { return false }

        return proposedText.matchesRegExp(pattern: pattern)
    }
}
