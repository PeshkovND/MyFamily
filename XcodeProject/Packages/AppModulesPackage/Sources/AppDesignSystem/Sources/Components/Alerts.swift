//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: - Alerts

extension UIViewController {

    // INFO: Workaround for providing deps here
    private var strings: StringsLibrary { .init() }

    public func showErrorAlert(_ error: Error, action: @escaping () -> Void = {}) {
        showAlert(
            title: strings.commonError,
            message: error.localizedDescription,
            actions: [.okAction(action: action)]
        )
    }

    public func showAlert(title: String?, message: String, actions: [UIAlertAction]) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        actions.forEach(alertController.addAction(_:))
        present(alertController, animated: true)
    }

    public func showAuthErrorAlert() {
        showAlert(
            title: strings.commonAuthErrorTitle,
            message: strings.commonAuthErrorMessage,
            actions: [.okAction()]
        )
    }
}

// MARK: - UIAlertAction

extension UIAlertAction {

    // INFO: Workaround for providing deps here
    private static var strings: StringsLibrary { .init() }

    public static func okAction(action: @escaping () -> Void = {}) -> UIAlertAction {
        .init(
            title: strings.commonOk,
            style: .default,
            handler: { _ in action() }
        )
    }

    public static func cancelAction(action: @escaping () -> Void = {}) -> UIAlertAction {
        .init(
            title: strings.commonCancel,
            style: .cancel,
            handler: { _ in action() }
        )
    }

    public static func closeAction() -> UIAlertAction {
        .init(title: strings.commonCancel, style: .default)
    }

    public static func openSettingsAction() -> UIAlertAction {
        .init(
            title: strings.commonOpenSettings,
            style: .default,
            handler: { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open( // swiftlint:disable:this explicit_singleton
                    url,
                    options: [:],
                    completionHandler: nil
                )
            }
        )
    }
}
