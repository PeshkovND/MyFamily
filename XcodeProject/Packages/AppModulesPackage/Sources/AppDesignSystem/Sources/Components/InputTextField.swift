//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import TweeTextField

extension TweeAttributedTextField {

    // MARK: InputTextField Providers

    static func makeExampleInputTextField() -> TweeAttributedTextField {
        let tweeAttributedTextField = TweeAttributedTextField()

        tweeAttributedTextField.infoAnimationDuration = 0.7
        tweeAttributedTextField.infoTextColor = .systemRed
        tweeAttributedTextField.infoFontSize = 13

        tweeAttributedTextField.activeLineColor = .systemBlue
        tweeAttributedTextField.activeLineWidth = 1
        tweeAttributedTextField.animationDuration = 0.3

        tweeAttributedTextField.lineColor = .lightGray
        tweeAttributedTextField.lineWidth = 1

        tweeAttributedTextField.minimumPlaceholderFontSize = 10
        tweeAttributedTextField.originalPlaceholderFontSize = 13
        tweeAttributedTextField.placeholderDuration = 0.3
        tweeAttributedTextField.placeholderColor = .systemGray2

        return tweeAttributedTextField
    }

    static func makeInputTextField(
        colors: Colors,
        typography: Typography
    ) -> TweeAttributedTextField {
        let tweeAttributedTextField = TweeAttributedTextField()

        tweeAttributedTextField.infoAnimationDuration = 0.3

        // TODO: Replace with colors
        tweeAttributedTextField.infoTextColor = .systemRed
        tweeAttributedTextField.infoLabel.font = typography.caption1

        tweeAttributedTextField.minimumPlaceholderFontSize = 12
        tweeAttributedTextField.originalPlaceholderFontSize = 16
        tweeAttributedTextField.animationDuration = 0.3

        // line color should use separator color
        tweeAttributedTextField.activeLineColor = colors.backgroundSecondary
        tweeAttributedTextField.lineColor = colors.labelSecondary
        tweeAttributedTextField.lineWidth = 1
        tweeAttributedTextField.placeholderLabel.font = typography.body

        tweeAttributedTextField.font = typography.body
        tweeAttributedTextField.textColor = colors.labelPrimary
        tweeAttributedTextField.placeholderColor = colors.labelSecondary

        return tweeAttributedTextField
    }

    // MARK: - Show/Hide Error

    public func showError(message: String, animated: Bool = true) {
        activeLineColor = .systemRed
        lineColor = .systemRed
        placeholderColor = .systemRed

        showInfo(message, animated: animated)
    }

    public func hideError(animated: Bool = true) {
        // TODO: Refactor using colors
        let colors = Colors()
        activeLineColor = colors.backgroundSecondary
        lineColor = colors.labelSecondary
        placeholderColor = colors.labelSecondary

        hideInfo(animated: animated)
    }
}
