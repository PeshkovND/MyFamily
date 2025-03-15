//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

final class FamilyCheckingViewController: BaseViewController<FamilyCheckingViewModel,
                                                               FamilyCheckingViewEvent,
                                                               FamilyCheckingViewState,
                                                               FamilyCheckingViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    private var loadingView: UIView { contentView.loadingView }
    
    private var isLoadingShowing = false {
        willSet {
            UIView.animate {
                loadingView.alpha = newValue ? 1 : 0
            }
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !newValue
        }
    }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onViewEvent(.viewDidAppear)
        loadingView.alpha = 1
    }
    
    override func onViewState(_ viewState: FamilyCheckingViewState) {
        switch viewState {
        case let .error(title, subtitle):
            isLoadingShowing = false
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addAction(.okAction(action: { [weak self] in
                self?.viewModel.onViewEvent(.retryButtonTapped)
            }))
            self.present(alert, animated: true)
        case .loading:
            isLoadingShowing = true
        }
    }
}
