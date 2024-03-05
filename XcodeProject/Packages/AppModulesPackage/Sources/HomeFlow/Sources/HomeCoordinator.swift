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
            makeNewsViewController(),
            makeFamilyViewController(),
            makeMapViewController(),
            makeProfileViewController()
        ]
        
        navigationController?.setViewControllers([tabBarController], animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func makeNewsViewController() -> UIViewController {
        
        let viewModel = NewsViewModel()
        let viewController = NewsViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarNewsTitle
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .addPost:
                    break
                }
            }
            .store(in: &setCancelable)
        
        let nvc = UINavigationController(rootViewController: viewController)
        viewController.tabBarItem = appDesignSystem.components.newsTabBarItem
        return nvc
    }
    
    func makeFamilyViewController() -> UIViewController {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "Family Screen"
        viewController.tabBarItem = appDesignSystem.components.familyTabBarItem
        return viewController
    }
    
    func makeMapViewController() -> UIViewController {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "Map Screen"
        viewController.tabBarItem = appDesignSystem.components.mapTabBarItem
        return viewController
    }
    
    func makeProfileViewController() -> UIViewController {
        let viewController = TitleStubViewController()
        viewController.stubTitle = "My Profile Screen"
        viewController.tabBarItem = appDesignSystem.components.profileTabBarItem
        
        return viewController
    }
}
