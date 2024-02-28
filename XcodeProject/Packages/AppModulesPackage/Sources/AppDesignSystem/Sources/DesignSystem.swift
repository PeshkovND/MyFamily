//
//  Copyright © 2021 Krasavchik OOO. All rights reserved.
//

import UIKit
import Utilities

// swiftlint:disable closure_body_length
public let appDesignSystem: DesignSystem = {
    let colors = Colors()
    let icons = IconsLibrary()
    let strings = StringsLibrary()
    let formatter = Formatter()
    let spacing = Spacing()
    let typography = Typography()
    let styles = Styles(
        colors: colors,
        typography: typography
    )
    let components = Components(
        colors: colors,
        icons: icons,
        strings: strings,
        typography: typography
    )

    let appDesignSystem = DesignSystem(
        colors: colors,
        icons: icons,
        strings: strings,
        formatter: formatter,
        spacing: spacing,
        typography: typography,
        styles: styles,
        components: components
    )

    return appDesignSystem
}()
// swiftlint:enable closure_body_length

public struct DesignSystem {

    public let colors: Colors
    public let icons: IconsLibrary
    public let strings: StringsLibrary
    public let formatter: Formatter
    public let spacing: Spacing
    public let typography: Typography
    public let styles: Styles
    public let components: Components

    init(
        colors: Colors,
        icons: IconsLibrary,
        strings: StringsLibrary,
        formatter: Formatter,
        spacing: Spacing,
        typography: Typography,
        styles: Styles,
        components: Components
    ) {
        self.colors = colors
        self.icons = icons
        self.strings = strings
        self.formatter = formatter
        self.spacing = spacing
        self.typography = typography
        self.styles = styles
        self.components = components
    }
}
