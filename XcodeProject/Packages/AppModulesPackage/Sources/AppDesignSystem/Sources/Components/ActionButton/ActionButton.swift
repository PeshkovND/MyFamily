//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

public class ActionButton: UIButton {

    // INFO: Ideally to use unified publisher for any events
    public var touchUpInsidePublisher: AnyPublisher<Void, Never> {
        touchUpInsideSubject.eraseToAnyPublisher()
    }

    private var touchUpInsideSubject: PassthroughSubject<Void, Never> = .init()

    public var titleFont: UIFont? {
        get {
            return titleLabel?.font
        }
        set {
            titleLabel?.font = newValue
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }

    public override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    public var onTap: (() -> Void)?

    private var style: ActionButtonStyle = StubActionButtonStyle()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(tap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(style: ActionButtonStyle) {
        self.style = style

        titleLabel?.adjustsFontSizeToFitWidth = true
        contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 8)

        style.setup(for: self)
    }

    public func setWithCaption(style: ActionButtonStyle, typography: Typography) {
        self.style = style

        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.font = typography.caption1
        contentEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
        addTarget(self, action: #selector(tap), for: .touchUpInside)

        style.setup(for: self)
    }

    private func updateAppearance() {
        style.apply(to: self)
    }

    @objc private func tap() {
        if let onTap = onTap {
            onTap()
        } else {
            touchUpInsideSubject.send()
        }
    }
}
