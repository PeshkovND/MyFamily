//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import AppDesignSystem

open class BaseView: UIView {

    private var designSystem = appDesignSystem
    private(set) public lazy var colors = designSystem.colors
    private(set) public lazy var icons = designSystem.icons
    private(set) public lazy var spacing = designSystem.spacing
    private(set) public lazy var typography = designSystem.typography
    private(set) public lazy var components = designSystem.components

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
