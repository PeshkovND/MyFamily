//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public final class TextViewCustomInteractionHandler: NSObject, UITextViewDelegate {

    private let actionName: String
    private let actionHandler: () -> Void

    public init(actionName: String, actionHandler: @escaping () -> Void) {
        self.actionName = actionName
        self.actionHandler = actionHandler
        super.init()
    }

    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        let hasValidAction = URL.absoluteString == actionName
        guard hasValidAction else { return false }

        actionHandler()

        return false
    }
}
