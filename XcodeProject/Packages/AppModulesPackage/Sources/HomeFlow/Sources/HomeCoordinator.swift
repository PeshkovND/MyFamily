//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppDesignSystem
import AppBaseFlow
import AppDevTools
import AppServices
import AVFoundation

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
    private let tabBarController = UITabBarController()
    private let debugTogglesHolder: DebugTogglesHolder
    private let authService: AuthService
    private let audioPlayer: AVQueuePlayer
    
    public init(
        navigationController: UINavigationController,
        authService: AuthService,
        debugTogglesHolder: DebugTogglesHolder,
        audioPlayer: AVQueuePlayer
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.debugTogglesHolder = debugTogglesHolder
        self.audioPlayer = audioPlayer
    }
    
    public func start() {
        startHomeScreen()
    }
    
    public func openPost(id: String) {
        startHomeScreen()
        let nvc = tabBarController.viewControllers?[0] as? UINavigationController
        openPostScreen(id: id, nvc: nvc ?? UINavigationController(), animated: false)
    }
}

// MARK: - Home Screen

private extension HomeCoordinator {
    
    private func startHomeScreen() {
        
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
    
    func makeNewsViewController() -> UINavigationController {
        
        let viewModel = NewsViewModel(audioPlayer: audioPlayer)
        let viewController = NewsViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarNewsTitle
        let nvc = UINavigationController(rootViewController: viewController)
        nvc.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        viewController.navigationItem.backButtonTitle = ""
        viewController.tabBarItem = appDesignSystem.components.newsTabBarItem
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                switch event {
                case .addPost:
                    break
                case .openUserProfile(id: let id):
                    self?.openProfileScreen(id: id, nvc: nvc)
                }
            }
            .store(in: &setCancelable)
        return nvc
    }
    
    func makeFamilyViewController() -> UIViewController {
                
        let viewModel = FamilyViewModel()
        let viewController = FamilyViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarFamilyTitle
        
        let nvc = UINavigationController(rootViewController: viewController)
        nvc.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        viewController.navigationItem.backButtonTitle = ""
        viewController.tabBarItem = appDesignSystem.components.familyTabBarItem
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard self != nil else { return }
                switch event {
                case .personCardTapped(let id):
                    self?.openProfileScreen(id: id, nvc: nvc)
                }
            }
            .store(in: &setCancelable)
        return nvc
    }
    
    func makeMapViewController() -> UIViewController {
        let viewModel = MapViewModel()
        let viewController = MapViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarMapTitle
        
//        viewModel.outputEventPublisher
//            .sink { [weak self] event in
//                guard self != nil else { return }
//                switch event {
//                case .personCardTapped(let id):
//                    break
//                }
//            }
//            .store(in: &setCancelable)
        
        let nvc = UINavigationController(rootViewController: viewController)
        viewController.tabBarItem = appDesignSystem.components.mapTabBarItem
        return nvc
    }
    
    func makeProfileViewController() -> UIViewController {
        let viewModel = ProfileViewModel(userId: "1", audioPlayer: audioPlayer)
        let viewController = ProfileViewController(viewModel: viewModel)
        
//        viewModel.outputEventPublisher
//            .sink { [weak self] event in
//                guard let self = self else { return }
//                
//                switch event {
//                case .addPost:
//                    break
//                }
//            }
//            .store(in: &setCancelable)
        
        let nvc = UINavigationController(rootViewController: viewController)
        viewController.tabBarItem = appDesignSystem.components.profileTabBarItem
        viewController.title = appDesignSystem.strings.tabBarProfileTitle
        return nvc
    }
    
    private func openProfileScreen(id: String, nvc: UINavigationController) {
        let viewModel = ProfileViewModel(userId: id, audioPlayer: self.audioPlayer)
        let viewController = ProfileViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarProfileTitle
        nvc.pushViewController(viewController, animated: true)
    }
    
    private func openPostScreen(id: String, nvc: UINavigationController, animated: Bool) {
        let viewModel = PostViewModel(postId: id, audioPlayer: self.audioPlayer)
        let viewController = PostViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.postScreenTitle
        nvc.pushViewController(viewController, animated: animated)
    }
}
