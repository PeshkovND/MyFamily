//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

/// This class enables inks and disables any selection on text and link
public final class NoSelectionTextView: UITextView {

    // Based on: https://stackoverflow.com/a/62024741
    public override var selectedTextRange: UITextRange? {
        get { return nil }

        // INFO: We have to override setter due to mutable property
        set { }
    }

    // Based on: https://stackoverflow.com/a/62024741
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer,
           tapGestureRecognizer.numberOfTapsRequired == 1 {
            // required for compatibility with links
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        return false
    }

    // Based on: https://stackoverflow.com/a/44878203
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        guard let postion = closestPosition(to: point) else { return false }

        guard let range = tokenizer.rangeEnclosingPosition(
                postion,
                with: .character,
                inDirection: .layout(.left)
        ) else {
            return false
        }

        let startIndex = offset(from: beginningOfDocument, to: range.start)
        let hasLinkAttribute = attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
        return hasLinkAttribute
    }
}
