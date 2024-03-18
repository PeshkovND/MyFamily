//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

public final class SignInCoordinator: EventCoordinator {

    public enum SignInEvent {
        case exit
        case finish(authState: AuthState)
    }

    public var events: AnyPublisher<SignInEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var eventsCancelableToken: AnyCancellable?

    private var setCancelable = Set<AnyCancellable>()

    private var eventSubject: PassthroughSubject<Event, Never> = .init()

    private let signInInteractor: SignInInteractor
    private let authService: AuthService
    private let vkIdSignInClient: VKIDClient
    private var designSystem = appDesignSystem

    private weak var navigationController: UINavigationController?

    public init(navigationController: UINavigationController, authService: AuthService, vkIdClient: VKIDClient) {
        self.navigationController = navigationController
        self.authService = authService
        self.signInInteractor = SignInInteractor(authService: authService)
        self.vkIdSignInClient = vkIdClient
    }

    public func start() {
        startSignInScreen()
    }
}

// MARK: - Starting Screens

private extension SignInCoordinator {

    private func startSignInScreen() {
        let viewModel = SignInViewModel(vkIdSignInClient: vkIdSignInClient)
        let viewController = SignInViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.commonSignIn

        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .signedIn: self.eventSubject.send(.finish(authState: .signIn))
                case .back: self.eventSubject.send(.exit)
                }
            }
            .store(in: &setCancelable)

        navigationController?.setViewControllers([viewController], animated: true)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
