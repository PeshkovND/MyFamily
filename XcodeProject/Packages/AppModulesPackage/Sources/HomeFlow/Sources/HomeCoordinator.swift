//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppDesignSystem
import AppBaseFlow
import AppDevTools
import AppServices

public final class HomeCoordinator: BaseCoordinator, EventCoordinator {

    public enum HomeEvent {
        case finished
    }

    public var events: AnyPublisher<HomeEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    public var eventsCancelableToken: AnyCancellable?

    private var designSystem = appDesignSystem

    private var eventSubject: PassthroughSubject<Event, Never> = .init()
    private var setCancelable = Set<AnyCancellable>()

    private weak var navigationController: UINavigationController?
    private let debugTogglesHolder: DebugTogglesHolder
    private let authService: AuthService

    public init(
        navigationController: UINavigationController,
        authService: AuthService,
        debugTogglesHolder: DebugTogglesHolder
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.debugTogglesHolder = debugTogglesHolder
    }

    public func start() {
        startHomeScreen()
    }
}

// MARK: - Home Screen

private extension HomeCoordinator {
    
    private func startHomeScreen() {
        let tabBarController = UITabBarController()

        tabBarController.tabBar.standardAppearance = appDesignSystem.components.tabbarStandardAppearance

        tabBarController.viewControllers = [
            makeHomeViewController(),
            makeStoreViewController(),
            makeProfileViewController()
        ]

        navigationController?.setViewControllers([tabBarController], animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if debugTogglesHolder.toggleValue(for: .isUserProfileFeatureEnabled) {
            tabBarController.selectedIndex = 2
        }
    }
    
    func makeHomeViewController() -> UIViewController {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "Home Screen"
        viewController.tabBarItem = appDesignSystem.components.exploreTabBarItem
        return viewController
    }

    func makeStoreViewController() -> UIViewController {
        let viewController = TitleStubViewController()

        // Stub data
        viewController.stubTitle = "Store Screen"

        viewController.tabBarItem = appDesignSystem.components.storeTabBarItem
        return viewController
    }

    func makeProfileViewController() -> UIViewController {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "My Profile Screen"
        viewController.tabBarItem = appDesignSystem.components.profileTabBarItem

        return viewController
    }
}
