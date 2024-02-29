//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

final class SignInViewController: BaseViewController<SignInViewModel,
                                                               SignInViewEvent,
                                                               SignInViewState,
                                                               SignInViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper

    deinit {
        viewModel.onViewEvent(.deinit)
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        viewModel.onViewEvent(.viewDidLoad)
    }
}
