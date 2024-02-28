//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: - ActionButtonStyle

public protocol ActionButtonStyle {

    func setup(for button: UIButton)
    func applyNormalAppearance(to button: UIButton)
    func applyHighlightedAppearance(to button: UIButton)
    func applyDisabledAppearance(to button: UIButton)
    func applyContentAppearance(to button: UIButton)
}

struct StubActionButtonStyle: ActionButtonStyle {
    func setup(for button: UIButton) {}
    func applyNormalAppearance(to button: UIButton) {}
    func applyHighlightedAppearance(to button: UIButton) {}
    func applyDisabledAppearance(to button: UIButton) {}
    func applyContentAppearance(to button: UIButton) {}
}

// MARK: - ActionButtonState

enum ActionButtonState {
    case normal
    case highlighted
    case disabled
}

// MARK: - ActionButtonStyle + Extensions

extension ActionButtonStyle {

    func apply(to button: UIButton) {
        switch actionButtonState(for: button) {
        case .normal:
            applyNormalAppearance(to: button)
        case .highlighted:
            applyHighlightedAppearance(to: button)
        case .disabled:
            applyDisabledAppearance(to: button)
        }
    }

    func actionButtonState(for button: UIButton) -> ActionButtonState {
        if button.isEnabled && !button.isHighlighted { return .normal }
        if button.isEnabled && button.isHighlighted { return .highlighted }
        if !button.isEnabled { return .disabled }

        return .normal
    }

    func defaultSetup(to button: UIButton) {
        applyNormalAppearance(to: button)
        applyContentAppearance(to: button)
    }
}

// MARK: - RoundedActionButtonStyle

struct RoundedActionButtonStyle: ActionButtonStyle {
    
    private let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    public func setup(for button: UIButton) {
        button.layer.cornerRadius = cornerRadius
    }
    
    public func applyNormalAppearance(to button: UIButton) {}
    
    public func applyHighlightedAppearance(to button: UIButton) {}
    
    public func applyDisabledAppearance(to button: UIButton) {}
    
    public func applyContentAppearance(to button: UIButton) {}
}

struct ContentActionButtonStyle: ActionButtonStyle {
    
    private let interItemSpacing: CGFloat
    private let cornerRadius: CGFloat
    
    init(interItemSpacing: CGFloat, cornerRadius: CGFloat) {
        self.interItemSpacing = interItemSpacing
        self.cornerRadius = cornerRadius
    }
    
    public func setup(for button: UIButton) {
        let itemInset: CGFloat = interItemSpacing / 2
        
        button.titleEdgeInsets = .init(
            top: 0, left: itemInset, bottom: 0, right: -itemInset
        )
        button.imageEdgeInsets = .init(
            top: 0, left: -itemInset, bottom: 0, right: itemInset
        )
        
        let contentInsets = button.contentEdgeInsets
        let hExtraInset: CGFloat = cornerRadius == 0 ? 0 : cornerRadius - contentInsets.left
        let hAdjustedCurrentContentInset: CGFloat = contentInsets.left + itemInset
        let hContentInset = hAdjustedCurrentContentInset + hExtraInset + itemInset
        button.contentEdgeInsets = .init(
            top: contentInsets.top,
            left: hContentInset,
            bottom: contentInsets.bottom,
            right: hContentInset
        )
        
        button.layer.cornerRadius = cornerRadius
    }
    
    public func applyNormalAppearance(to button: UIButton) {}
    
    public func applyHighlightedAppearance(to button: UIButton) {}
    
    public func applyDisabledAppearance(to button: UIButton) {}
    
    public func applyContentAppearance(to button: UIButton) {}
}

// MARK: - PrimaryActionButtonStyle

public struct PrimaryActionButtonStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor { colors.backgroundSecondary }
    private var disabledBackgroundColor: UIColor { colors.backgroundSecondaryDisabled }

    private var normalTextColor: UIColor { colors.labelPrimaryVariant }
    private var disabledTextColor: UIColor { colors.labelPrimaryVariant }

    private let colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        button.backgroundColor = normalBackgroundColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        button.backgroundColor = disabledBackgroundColor
    }

    public func applyContentAppearance(to button: UIButton) {
        button.setTitleColor(normalTextColor, for: .normal)
        button.setTitleColor(disabledTextColor, for: .disabled)
    }
}

// MARK: - TextButtonStyle

public struct TextButtonStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor { colors.backgroundPrimary }
    private var disabledBackgroundColor: UIColor { colors.backgroundPrimary }

    private var normalTextColor: UIColor { .systemBlue }
    private var disabledTextColor: UIColor { colors.labelSecondary }

    private let colors: Colors
    private let typography: Typography

    init(colors: Colors, typography: Typography) {
        self.colors = colors
        self.typography = typography
    }

    public func setup(for button: UIButton) {
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        button.titleLabel?.font = typography.headline
        button.backgroundColor = normalBackgroundColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        button.titleLabel?.font = typography.subheadline
        button.backgroundColor = disabledBackgroundColor
    }

    public func applyContentAppearance(to button: UIButton) {
        button.setTitleColor(normalTextColor, for: .normal)
        button.setTitleColor(disabledTextColor, for: .disabled)
    }
}

public struct CompletedActionButtonStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor { colors.backgroundSecondary }
    private var disabledBackgroundColor: UIColor { colors.backgroundPrimary }
    private var disableBorderColor: UIColor { colors.backgroundSecondary }

    private var normalTextColor: UIColor { colors.labelPrimaryVariant }
    private var disabledTextColor: UIColor { colors.labelPrimary }

    private let colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        button.backgroundColor = normalBackgroundColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        button.backgroundColor = disabledBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = disableBorderColor.cgColor
    }

    public func applyContentAppearance(to button: UIButton) {
        button.setTitleColor(normalTextColor, for: .normal)
        button.setTitleColor(disabledTextColor, for: .disabled)
    }
}

public struct BorderedButtonStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor { colors.backgroundPrimary }
    private var normalBorderColor: UIColor { colors.backgroundSecondary }

    private var normalTextColor: UIColor { colors.labelPrimary }

    private let colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        button.backgroundColor = normalBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = normalBorderColor.cgColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        // INFO: Don't use Disabled state
    }

    public func applyContentAppearance(to button: UIButton) {
        button.setTitleColor(normalTextColor, for: .normal)
    }
}

public struct FilledActionStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor { colors.backgroundTertiary }

    private var normalTextColor: UIColor { colors.labelPrimary }

    private let parentStyle: ActionButtonStyle?
    private let colors: Colors

    // TODO: It should be internal
    public init(parentStyle: ActionButtonStyle? = nil, colors: Colors) {
        self.parentStyle = parentStyle
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        parentStyle?.setup(for: button)
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        parentStyle?.applyNormalAppearance(to: button)
        button.backgroundColor = normalBackgroundColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        parentStyle?.applyHighlightedAppearance(to: button)
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        parentStyle?.applyDisabledAppearance(to: button)
        // INFO: Don't use Disabled state
    }

    public func applyContentAppearance(to button: UIButton) {
        parentStyle?.applyContentAppearance(to: button)
        button.setTitleColor(normalTextColor, for: .normal)
    }
}

public struct BadgeActionStyle: ActionButtonStyle {

    private var normalBackgroundColor: UIColor {
        // INFO: Need to revise color palette
        UIColor.black.withAlphaComponent(0.12)
    }

    private var normalTextColor: UIColor { colors.labelPrimary }
    private var normalImageColor: UIColor { colors.fillPrimary }

    private let parentStyle: ActionButtonStyle?
    private let colors: Colors

    init(parentStyle: ActionButtonStyle? = nil, colors: Colors) {
        self.parentStyle = parentStyle
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        parentStyle?.setup(for: button)
        defaultSetup(to: button)
    }

    public func applyNormalAppearance(to button: UIButton) {
        parentStyle?.applyNormalAppearance(to: button)
        button.backgroundColor = normalBackgroundColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        parentStyle?.applyHighlightedAppearance(to: button)
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        parentStyle?.applyDisabledAppearance(to: button)
        // INFO: Don't use Disabled state
    }

    public func applyContentAppearance(to button: UIButton) {
        parentStyle?.applyContentAppearance(to: button)
        button.setTitleColor(normalTextColor, for: .normal)
        button.tintColor = normalImageColor
    }
}

public struct DisableBorderedStyle: ActionButtonStyle {

    private var dasabledBackgroundColor: UIColor { colors.backgroundPrimary }
    private var disabledBorderColor: UIColor { colors.backgorundBorderDisabled }
    private var dasabledTextColor: UIColor { colors.labelPrimary }

    private let colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public func setup(for button: UIButton) {
        defaultSetup(to: button)

    }

    public func applyNormalAppearance(to button: UIButton) {
        button.backgroundColor = dasabledBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = disabledBorderColor.cgColor
    }

    public func applyHighlightedAppearance(to button: UIButton) {
        // INFO: Use default highlighting
    }

    public func applyDisabledAppearance(to button: UIButton) {
        // INFO: Doen't use Disabled
    }

    public func applyContentAppearance(to button: UIButton) {
        button.setTitleColor(dasabledTextColor, for: .normal)
        button.adjustsImageWhenDisabled = false
        button.tintColor = dasabledTextColor
    }
}
