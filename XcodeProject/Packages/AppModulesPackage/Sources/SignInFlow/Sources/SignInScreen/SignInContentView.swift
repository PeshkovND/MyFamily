//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import TweeTextField
import AppBaseFlow

extension SignInViewController {

    final class ContentView: BaseView {

        private(set) lazy var headlineLabel: UILabel = {
            let label = UILabel()
            label.font = typography.headline
            label.textColor = colors.labelPrimary
            label.numberOfLines = 0
            return label
        }()

        private(set) lazy var inputTextField: TweeAttributedTextField = {
            let textField = components.inputTextField
            textField.keyboardType = .phonePad
            return textField
        }()

        private(set) lazy var captionLabel: UILabel = {
            let label = UILabel()
            label.font = typography.caption1
            label.textColor = colors.labelSecondary
            return label
        }()

        private(set) lazy var actionButton = components.primaryActionButton

        // swiftlint:disable function_body_length
        override func setLayout() {
            backgroundColor = colors.backgroundPrimary

            let spaceView = UIView()
            addSubview(spaceView)
            addSubview(headlineLabel)
            addSubview(inputTextField)
            addSubview(captionLabel)
            addSubview(actionButton)

            spaceView.snp.makeConstraints {
                $0.top.equalTo(safeAreaLayoutGuide.snp.top)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                $0.height.equalTo(safeAreaLayoutGuide.snp.height).multipliedBy(0.15)
            }

            headlineLabel.snp.makeConstraints {
                $0.top.equalTo(spaceView.snp.bottom)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                    .inset(spacing.hPadding)
                $0.width.equalTo(snp.width).multipliedBy(0.45)
            }

            inputTextField.snp.makeConstraints {
                $0.top.equalTo(headlineLabel.snp.bottom).offset(56)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                    .inset(spacing.hPadding)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                    .inset(spacing.hPadding)
                $0.height.equalTo(56)
            }

            captionLabel.snp.makeConstraints {
                $0.bottom.equalTo(actionButton.snp.top)
                    .offset(-24)
                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                    .inset(spacing.hPadding)
                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                    .inset(spacing.hPadding)
            }

            actionButton.snp.makeConstraints {
                $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
                    .inset(spacing.vPadding)

                $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
                    .offset(spacing.hPadding)

                $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
                    .inset(spacing.hPadding)

                $0.height.equalTo(spacing.primaryActionButtonHeight)
            }
        }
        // swiftlint:enable function_body_length
    }
}
