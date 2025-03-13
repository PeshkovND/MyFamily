//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow
import TweeTextField

final class AddFamilyForkViewController: BaseViewController<AddFamilyForkViewModel,
                                         AddFamilyForkViewEvent,
                                         AddFamilyForkViewState,
                                         AddFamilyForkViewController.ContentView> {

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper
    private var createFamilyButton: ActionButton { contentView.createFamilyButton }
    private var enterExistFamilyButton: ActionButton { contentView.enterExistFamilyButton }
    private var logOutButton: ActionButton { contentView.logOutButton }
    private var helloTitle: UILabel { contentView.title }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        navigationController?.isNavigationBarHidden = true
        helloTitle.text = "Hello, \(viewModel.username). Create a new family or join an existing one"
    }
    
    override func onViewState(_ viewState: AddFamilyForkViewState) {
        switch viewState {
        case .initial:
            break
        }
    }
    
    private func configureView() {
            disableKeyboardAutoManaging = false

        createFamilyButton.touchUpInsidePublisher
                .sink { [weak self] _ in
                    self?.viewModel.onViewEvent(.addNewFamilyTapped)
                }
                .store(in: &cancelableSet)
        
        enterExistFamilyButton.touchUpInsidePublisher
            .sink { [weak self] _ in
                self?.viewModel.onViewEvent(.enterExistingFamilyTapped)
            }
            .store(in: &cancelableSet)
        
        
        logOutButton.touchUpInsidePublisher
            .sink { [weak self] _ in
                self?.viewModel.onViewEvent(.logOutTapped)
            }
            .store(in: &cancelableSet)
        }
}
