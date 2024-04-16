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
    
    private var signInButton: ActionButton { contentView.signInButton }
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        navigationController?.isNavigationBarHidden = true
        viewModel.onViewEvent(.viewDidLoad)
    }
    
    override func onViewState(_ viewState: SignInViewState) {
        switch viewState {
        case .failed(error: let error):
            let alert = UIAlertController(title: error?.alert?.title, message: error?.alert?.message, preferredStyle: .alert)
            alert.addAction(.cancelAction())
            self.present(alert, animated: true)
        case .initial:
            break
        case .loading:
            break
        case .loaded:
            break
        }
    }
    
    private func configureView() {
            disableKeyboardAutoManaging = false

            signInButton.touchUpInsidePublisher
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.onViewEvent(
                        .signInTapped
                    )
                }
                .store(in: &cancelableSet)
        }
}
