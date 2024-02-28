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

    private var designSystem = appDesignSystem
    private lazy var strings = appDesignSystem.strings

    private lazy var loadingViewHelper = appDesignSystem.components.loadingViewHelper

    private var inputTextField: TweeAttributedTextField { contentView.inputTextField }
    private var headlineLabel: UILabel { contentView.headlineLabel }
    private var captionLabel: UILabel { contentView.captionLabel }
    private var actionButton: ActionButton { contentView.actionButton }

    deinit {
        viewModel.onViewEvent(.deinit)
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        viewModel.onViewEvent(.viewDidLoad)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        inputTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        inputTextField.endEditing(true)
    }

    override func onViewState(_ viewState: SignInViewState) {
        switch viewState {
        case .initial: self.showInitialState()
        case .inputValidated(let validatingState): self.showValidatingState(validatingState)
        case .loading:
            self.hideFieldError()
            self.showLoadingView()
        case .loaded: self.dismissLoadingView()
        case .failed(let error):
            self.dismissLoadingView()
            self.showError(error)
        }
    }

    private func configureView() {
        disableKeyboardAutoManaging = false

        actionButton.touchUpInsidePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.onViewEvent(
                    .actionNext(phoneText: self.inputTextField.text ?? "")
                )
            }
            .store(in: &cancelableSet)

        // TODO: - Add handling text input
    }

    // MARK: - Handling View State

    private func showInitialState() {
        headlineLabel.text = strings.signInPhoneContentTitle
        inputTextField.tweePlaceholder = strings.commonPhoneNumber
        captionLabel.text = strings.signInPhoneCaption
        actionButton.setTitle(strings.commonContinue, for: .normal)
        actionButton.isEnabled = false
    }

    private func showValidatingState(_ state: SignInViewState.ValidatingState) {
        if let inputError = state.inputError {
            inputTextField.showError(message: inputError)
        } else {
            inputTextField.hideError()
        }

        actionButton.isEnabled = state.actionEnabled
    }

    private func dismissLoadingView() {
        loadingViewHelper.dismissLoadingView()
    }

    private func hideFieldError() {
        inputTextField.hideError()
    }

    private func showLoadingView() {
        loadingViewHelper.showLoadingViw(in: view, message: strings.commonLoading)
    }

    private func showError(_ screenError: SignInContext.ScreenError) {
        if let alert = screenError.alert {
            showAlert(
                title: alert.title,
                message: alert.message,
                actions: [.okAction()]
            )
        }

        if let fieldErrorDescription = screenError.fieldsInfo {
            inputTextField.showError(message: fieldErrorDescription)
        }
    }
}
