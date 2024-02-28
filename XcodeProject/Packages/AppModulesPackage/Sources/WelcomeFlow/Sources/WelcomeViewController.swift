//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import SnapKit
import AppDesignSystem
import AppBaseFlow

final class WelcomeViewController: BaseViewController<WelcomeViewModel,
                                                      WelcomeViewEvent,
                                                      WelcomeViewState,
                                                      WelcomeViewController.ContentView> {

    private var designSystem = appDesignSystem
    private lazy var strings = appDesignSystem.strings
    private lazy var colors = appDesignSystem.colors
    private lazy var spacing = appDesignSystem.spacing

    private var privacyTextView: UITextView { contentView.privacyTextView }
    private var signInButton: UIButton { contentView.singInButton }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        setPrivacyTextView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func configureView() {
        signInButton.addTarget(
            self,
            action: #selector(onTapSingUpWithMobilePhone),
            for: .touchUpInside
        )
    }

    @objc private func onTapSingUpWithMobilePhone() {
        viewModel.onViewEvent(
            .actionSignIn
        )
    }

    private func setPrivacyTextView() {
        privacyTextView.attributedText = viewModel.termsServiceAndPrivacyPolicyAttributedString
        privacyTextView.textAlignment = .center
    }
}
