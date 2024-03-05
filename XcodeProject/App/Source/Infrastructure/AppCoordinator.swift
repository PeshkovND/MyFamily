//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

import Utilities
import AppEntities
import AppServices
import AppBaseFlow
import WelcomeFlow
import SignInFlow
import AppDevTools
import HomeFlow

final class AppCoordinator: BaseCoordinator, Coordinator {

    private static var logger = LoggerFactory.default

    private let navigationController: UINavigationController = .init()
    private var window: UIWindow?

    // Dependencies
    private let debugTogglesHolder = AppContainer.provideDebugTogglesHolder()
    private let env: Env = AppContainer.provideEnv()
    private let debugStorage = AppContainer.provideDebugDefaultsStorage()
    private let defaultsStorage = AppContainer.provideDefaultsStorage()
    private var authService = AppContainer.provideAuthService()
    private lazy var logoutNotifier: LogoutNotifier = authService
    private var accountHolder: AccountHolder { authService }

    // Debug panel for testing
    private var inAppDebugger: InAppDebugger?
    private var notificationCenter: NotificationCenter { .default }
    private var switchingEnvSubscription: AnyCancellable?

    func start() {
        initWindow()

        logoutNotifier.onLogoutCompleted = { [weak self] in
            guard let self = self else { return }
            self.removeAll()
            self.startSignInFlow()
        }

        logoutNotifier.onAuthErrorOccured = { [weak self] in
            guard let self = self else { return }
            self.removeAll()
            self.startSignInFlow()
            self.showAuthErrorAlert()
        }

        if debugTogglesHolder.toggleValue(for: .isOnboardingFeatureEnabled) {
            startOnboardingFlow()
            return
        }

        if authService.hasAuthorizedUser {
            startAuthorizedFlow()
        } else {
            startSignInFlow()
        }
    }

    private func initWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        setInAppDebuggerIfNeeded(window)
    }
}

// MARK: - App Root Flows

private extension AppCoordinator {

    private func startAuthorizedFlow() {
        startHomeFlow()
    }

    private func startWelcomeFlow() {
        let coordinator = WelcomeCoordinator(
            navigationController: navigationController
        )
        let token = coordinator.events.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .signIn: self.startSignInFlow()
            }
        }
        addDependency(coordinator, token: token)
        coordinator.start()
    }

    private func startSignInFlow() {
        let coordinator = SignInCoordinator(
            navigationController: navigationController,
            authService: authService
        )

        let token = coordinator.events.sink { [weak self, weak coordinator] event in
            guard let self = self else { return }

            switch event {
            case .exit:
                guard let coordinator = coordinator else { return }
                self.removeDependency(coordinator)
            case .finish(let authState):
                self.handleFinishedSignInFlow(with: authState)
            }
        }
        addDependency(coordinator, token: token)
        coordinator.start()
    }

    private func handleFinishedSignInFlow(with authState: AuthState) {
        removeAll()
        switch authState {
        case .signIn:
            startAuthorizedFlow()
        case .signUp:
            startCreateProfileFlow()
        }
    }

    private func startHomeFlow() {
        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            authService: authService,
            debugTogglesHolder: debugTogglesHolder
        )
        let token = coordinator.events.sink { _ in
            // IMPLEMENT: Event handling
        }
        addDependency(coordinator, token: token)
        coordinator.start()
    }

    private func startCreateProfileFlow() {
        let coordinator = StubFlowCoordinator(
            navigationController: navigationController
        )
        let token = coordinator.events.sink { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .finish:
                self.removeAll()
                self.startHomeFlow()
            }
        }
        addDependency(coordinator, token: token)
        coordinator.start()
    }
    
    private func startOnboardingFlow() {
        let coordinator = StubFlowCoordinator(
            navigationController: navigationController
        )
        addDependency(coordinator)
        coordinator.start()
    }

    private func showAuthErrorAlert() {
        navigationController.showAuthErrorAlert()
    }
    
    private func saveCompletedOnboarding() {
        defaultsStorage.add(
            primitiveValue: true,
            forKey: GlobalConfig.Keys.onboardingCompleted
        )
    }
    
    private func hasOnboardingCompleted() -> Bool {
        defaultsStorage.primitiveValue(
            forKey: GlobalConfig.Keys.onboardingCompleted
        ) ?? false
    }
}

// MARK: - Debugging

private extension AppCoordinator {

    private func setInAppDebuggerIfNeeded(_ window: UIWindow) {
        switch env.buildType {

        case .qa, .debug:
            inAppDebugger = .init(window: window)
            inAppDebugger?.attach(
                debugView: DebugView(
                    authService: authService,
                    debugStorage: debugStorage,
                    env: env
                )
            )

            switchingEnvSubscription = notificationCenter
                .publisher(for: .appDebugDidEnvChanged)
                .sink { [weak self] _ in
                    guard let self = self else { return }

                    // TODO: Implement logout and clean
                    self.startSignInFlow()
                    self.showInfoAlertAboutSwitchEnv()
                }
        case .production, .unknown: break
        }
    }

    private func showInfoAlertAboutSwitchEnv() {
        let alert = UIAlertController(
            title: "Environment has changed!",
            message: "Used \(env.apiBaseUrlString).\nPlease close the app, remove it from recent apps and open it again.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Оk",
                style: .default,
                handler: nil
            )
        )

        navigationController.present(alert, animated: true, completion: nil)

        Self.logger.info(
            message: "Application change environment: \(AppContainer.provideEnv())"
        )
    }
}
