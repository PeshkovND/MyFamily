//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public class RoundedImageView: UIImageView {

    public override var bounds: CGRect {
        didSet {
            layer.cornerRadius = frame.height / 2
            clipsToBounds = true
        }
    }

    public func setup(colors: Colors, typography: Typography) {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = colors.backgroundSecondary.cgColor
        contentMode = .center
    }
}

public final class NamedAvatarImageView: RoundedImageView {
    
    public var label: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue?.uppercased()
        }
    }

    var font: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    private let titleLabel: UILabel = .init()

    public override func setup(colors: Colors, typography: Typography) {
        super.setup(colors: colors, typography: typography)
        
        titleLabel.font = typography.headline
        titleLabel.textColor = colors.labelPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        let verticalConstraint = titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
    }
    
    public func hideLabel() {
        titleLabel.isHidden = true
    }
    
    public func showLabel() {
        titleLabel.isHidden = false
    }
}
