//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppBaseFlow

public final class WelcomeCoordinator: EventCoordinator {

    public enum WelcomeEvent {
        case signIn
    }

    public var events: AnyPublisher<WelcomeEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var eventsCancelableToken: AnyCancellable?

    private var setCancelable = Set<AnyCancellable>()

    private var eventSubject: PassthroughSubject<Event, Never> = .init()

    private weak var navigationController: UINavigationController?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        startWelcomeScreen()
    }
}

// MARK: - Starting Screens

private extension WelcomeCoordinator {

    private func startWelcomeScreen() {
        let viewModel = WelcomeViewModel()
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .continue: self.eventSubject.send(.signIn)
                }
            }
            .store(in: &setCancelable)

        let viewController = WelcomeViewController(viewModel: viewModel)
        navigationController?.setViewControllers([viewController], animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
