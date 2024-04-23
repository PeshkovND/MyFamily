//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import AppDesignSystem

open class BaseView: UIView {

    private var designSystem = appDesignSystem
    public private(set) lazy var colors = designSystem.colors
    public private(set) lazy var icons = designSystem.icons
    public private(set) lazy var strings = designSystem.strings
    public private(set) lazy var spacing = designSystem.spacing
    public private(set) lazy var typography = designSystem.typography
    public private(set) lazy var components = designSystem.components

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setLayout() {
        assertionFailure("It must be overriden in subclass")
    }
}
