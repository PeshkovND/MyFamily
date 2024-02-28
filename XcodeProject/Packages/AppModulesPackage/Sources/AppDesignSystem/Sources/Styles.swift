//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Utilities

public struct Styles {

    private let colors: Colors
    private let typography: Typography

    init(colors: Colors, typography: Typography) {
        self.colors = colors
        self.typography = typography
    }
}

// MARK: - App Strings

extension Styles {

    public var screenSubheadlineAttributes: StringAttributes {
        [
            .foregroundColor: colors.labelSecondary,
            .font: typography.subheadline
        ]
    }

    public var textViewLinkAttributes: StringAttributes {
        [.underlineStyle: NSUnderlineStyle.single.rawValue]
    }
}
