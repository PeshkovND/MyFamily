//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Utilities
import AppDesignSystem
import AppBaseFlow

extension WelcomeViewController {

    final class ContentView: BaseView {

        private var designSystem = appDesignSystem
        private lazy var styles = appDesignSystem.styles

        private(set) lazy var singInButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = appDesignSystem.colors.backgroundSecondary
            button.setTitle(strings.commonSignIn, for: .normal)
            return button
        }()

        private(set) lazy var privacyTextView: UITextView = {
            let textView = NoSelectionTextView()
            textView.textContainer.lineFragmentPadding = 0
            textView.isScrollEnabled = false
            textView.isEditable = false
            return textView
        }()

        override func setLayout() {
            backgroundColor = appDesignSystem.colors.backgroundPrimary

            addSubview(privacyTextView)
            privacyTextView.snp.makeConstraints {
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leadingMargin).offset(20)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailingMargin).inset(20)
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin).inset(spacing.vPadding)
            }

            addSubview(singInButton)
            singInButton.snp.makeConstraints {
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leadingMargin).offset(spacing.hPadding)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailingMargin).inset(spacing.hPadding)
                $0.bottom.equalTo(privacyTextView.snp.topMargin).offset(-24)
                $0.height.equalTo(48)
            }

            let containerView = UIView()
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = colors.backgroundSecondary.cgColor
            addSubview(containerView)
            // Info: padding 1 is necessary for border in container view
            containerView.snp.makeConstraints {
                $0.bottom.equalTo(singInButton.snp.top).offset(-16)
                $0.top.equalTo(safeAreaLayoutGuide.snp.topMargin)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leadingMargin).offset(1)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailingMargin).inset(1)
            }
        }

    }
}
