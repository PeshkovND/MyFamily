//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

final class JoinFamilyViewController: BaseViewController<JoinFamilyViewModel,
                                                               JoinFamilyViewEvent,
                                                               JoinFamilyViewState,
                                                               JoinFamilyViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper

    private var joinFamilyButton: ActionButton { contentView.joinFamilyButton }
    private var backButton: ActionButton { contentView.backButton }
    private var loadingView: UIView { contentView.loadingView }
    private var codeInputField: UITextField { contentView.codeInputField }
    
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
        
        configureView()
        navigationController?.isNavigationBarHidden = true
    }
    
    override func onViewState(_ viewState: JoinFamilyViewState) {
        switch viewState {
        case let .error(title, subtitle):
            isLoadingShowing = false
            let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            alert.addAction(.cancelAction())
            self.present(alert, animated: true)
        case .initial:
            loadingView.alpha = 0
            isLoadingShowing = false
        case .loading:
            isLoadingShowing = true
        }
    }
    
    private func configureView() {
            disableKeyboardAutoManaging = false

            joinFamilyButton.touchUpInsidePublisher
                .sink { [weak self] _ in
                    guard
                        let self = self,
                        let code = self.codeInputField.text
                    else { return }
                    self.viewModel.onViewEvent(
                        .joinFamilyTapped(code: code)
                    )
                }
                .store(in: &cancelableSet)
        
        backButton.touchUpInsidePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.onViewEvent(
                    .backButtonTapped
                )
            }
            .store(in: &cancelableSet)
        }
}
