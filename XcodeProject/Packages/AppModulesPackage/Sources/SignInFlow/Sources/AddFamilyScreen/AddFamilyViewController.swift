//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

final class AddFamilyViewController: BaseViewController<AddFamilyViewModel,
                                                               AddFamilyViewEvent,
                                                               AddFamilyViewState,
                                                               AddFamilyViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper

    private var addFamilyButton: ActionButton { contentView.addFamilyButton }
    private var backButton: ActionButton { contentView.backButton }
    private var loadingView: UIView { contentView.loadingView }
    private var nameInputField: UITextField { contentView.nameInputField }
    
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
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: AddFamilyViewState) {
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

            addFamilyButton.touchUpInsidePublisher
                .sink { [weak self] _ in
                    guard let self = self, let name = self.nameInputField.text else { return }
                    self.viewModel.onViewEvent(
                        .addFamilyTapped(name: name)
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
