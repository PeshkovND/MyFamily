//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import AppDesignSystem

final class InputTextFieldExamplesViewController: UIViewController {

    private var designSystem = appDesignSystem

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
    }

    // swiftlint:disable function_body_length
    private func setLayout() {
        view.backgroundColor = appDesignSystem.colors.backgroundPrimary

        let titleLabel = makeTitleLabel()
        titleLabel.text = "Customization Options"
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(25)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        let usernameTitle = makeTitleLabel()
        usernameTitle.text = "TweeTextField: Default State"
        view.addSubview(usernameTitle)
        usernameTitle.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.topMargin).offset(25)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.equalTo(14)
        }

        let usernameTextField = appDesignSystem.components.tweeAttributedTextField
        view.addSubview(usernameTextField)
        usernameTextField.tweePlaceholder = "Username"
        usernameTextField.delegate = self
        usernameTextField.snp.makeConstraints {
            $0.top.equalTo(usernameTitle.snp.bottomMargin).offset(25)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.equalTo(45)
        }

        let passwordTitle = makeTitleLabel()
        passwordTitle.text = "TweeTextField: Error State"
        view.addSubview(passwordTitle)
        passwordTitle.snp.makeConstraints {
            $0.top.equalTo(usernameTextField.snp.bottomMargin).offset(35)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        let passwordTextField = appDesignSystem.components.tweeAttributedTextField
        view.addSubview(passwordTextField)
        passwordTextField.tweePlaceholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.delegate = self
        passwordTextField.showInfo("Error: something wrong", animated: true)
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTitle.snp.bottomMargin).offset(35)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.equalTo(45)
        }

        let styledLabel = makeTitleLabel()
        styledLabel.text = "Styled TweeTextField"
        view.addSubview(styledLabel)
        styledLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottomMargin).offset(70)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
        }

        let firstNameTextField = appDesignSystem.components.inputTextField
        view.addSubview(firstNameTextField)
        firstNameTextField.tweePlaceholder = "First name"
        firstNameTextField.delegate = self
        firstNameTextField.snp.makeConstraints {
            $0.top.equalTo(styledLabel.snp.bottomMargin).offset(35)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(16)
            $0.height.equalTo(40)
        }

        let lastNameTextField = appDesignSystem.components.inputTextField
        view.addSubview(lastNameTextField)
        lastNameTextField.tweePlaceholder = "Last name"
        lastNameTextField.text = "Doe"
        lastNameTextField.delegate = self
        lastNameTextField.snp.makeConstraints {
            $0.top.equalTo(firstNameTextField.snp.bottomMargin).offset(35)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(16)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(16)
            $0.height.equalTo(40)
        }
    }
    // swiftlint:enable function_body_length

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font.withSize(8)
        label.textAlignment = .center
        return label
    }
}

extension InputTextFieldExamplesViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
