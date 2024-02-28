//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine
import AppDesignSystem
import Utilities
import AppBaseFlow

final class WelcomeViewModel: BaseViewModel<WelcomeViewEvent,
                                            WelcomeViewState,
                                            WelcomeOutputEvent> {

    private(set) lazy var termsServiceAndPrivacyPolicyAttributedString: NSAttributedString = {
        let attributedText = strings.welcomeTermsServicePrivacyPolicy
            .attributed(with: [:])
            .apply(
                links: [
                    .init(
                        text: strings.welcomeTermsService,
                        url: GlobalConfig.AppURL.termsOfService
                    ),
                    .init(
                        text: strings.welcomePrivacyPolicy,
                        url: GlobalConfig.AppURL.privacyPolicy
                    )
                ],
                attributes: designSystem.styles.textViewLinkAttributes
            )
        return attributedText
    }()
    
    private var designSystem = appDesignSystem
    private lazy var strings = appDesignSystem.strings
    private lazy var styles = appDesignSystem.styles

    override func onViewEvent(_ event: WelcomeViewEvent) {
        switch event {
        case .actionSignIn:
            outputEventSubject.send(.continue)
        }
    }
}
