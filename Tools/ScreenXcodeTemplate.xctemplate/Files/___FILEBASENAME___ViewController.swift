//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//  Generated using Xcode Screen Template

import UIKit
import AppCoreUI

final class ___VARIABLE_productName:identifier___ViewController: BaseViewController<___VARIABLE_productName:identifier___ViewModel,
                                                        ___VARIABLE_productName:identifier___Context.ViewEvent,
                                                        ___VARIABLE_productName:identifier___Context.ViewState,
                                                        ___VARIABLE_productName:identifier___Context.ContentView> {

    private static var logger = AppContainer.provideDefaultLogger()

    private var coreUI = AppContainer.provideAppCoreUI()
    private lazy var strings = coreUI.strings

    // TODO: Provide views like example
    /*
    private var editProfileActionButton: ActionButton {
        contentView.editProfileActionButton
    }
    */

    deinit {
        viewModel.onViewEvent(.deinit)
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewActions()
        viewModel.onViewEvent(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.onViewEvent(.viewDidAppear)
    }

    override func onViewState(_ viewState: ___VARIABLE_productName:identifier___Context.ViewState) {
        switch viewState {

        case .initial:
            showInitialState()
        case .empty:
            break
        // TODO: Handle view states. Avoid using `default` case
        // case .
        }
    }

    // MARK: - Handling View State

    private func showInitialState() {
        // EXAMPLE
        /*
        editProfileActionButton.setTitle(strings.myProfileEdit, for: .normal)
        avatarImageView.label = profile.avatarLabel
        usernameLabel.text = profile.username
        userLevelActionButton.isUserInteractionEnabled = profile.levelActionEnabled
        userLevelActionButton.setTitle(profile.level, for: .normal)
        
        userLevelActionButton.setImage(coreUI.icons.award, for: .normal)
        
        myFriendsActionButton.setTitle(strings.myProfileMyFriends, for: .normal)
        mySettingActionButton.setTitle(strings.myProfileMySettings, for: .normal)
        */
    }
    
    private func showError(_ error: ___VARIABLE_productName:identifier___Context.ScreenError) {}

    private func bindViewActions() {
        // TODO: Implement action binding
        /*
        editProfileActionButton.touchUpInsidePublisher
            .sink { [weak self] _ in
                self?.viewModel.onViewEvent(.editProfile)
            }
            .store(in: &cancelableSet)
        */
    }
}
