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
        case signOut
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
    private let firebaseClient: FirebaseClient
    private let audioPlayer: AVPlayer
    private let swiftDataManager: SwiftDataManager
    private let sharePostDeeplinkBody = "mf://post/"
    
    public init(
        navigationController: UINavigationController,
        authService: AuthService,
        debugTogglesHolder: DebugTogglesHolder,
        audioPlayer: AVPlayer,
        firebaseClient: FirebaseClient,
        swiftDataManager: SwiftDataManager
    ) {
        self.navigationController = navigationController
        self.authService = authService
        self.debugTogglesHolder = debugTogglesHolder
        self.audioPlayer = audioPlayer
        self.firebaseClient = firebaseClient
        self.swiftDataManager = swiftDataManager
    }
    
    public func start() {
        startHomeScreen()
    }
    
    public func openPost(id: String) {
        startHomeScreen()
        let nvc = tabBarController.viewControllers?[0] as? UINavigationController
        openPostScreen(id: id, nvc: nvc ?? UINavigationController(), animated: false)
    }
    
    public func openNews() {
        startHomeScreen()
        tabBarController.selectedIndex = 0
    }
    
    public func openFamily() {
        startHomeScreen()
        tabBarController.selectedIndex = 1
    }
    
    public func openMap() {
        startHomeScreen()
        tabBarController.selectedIndex = 2
    }
    
    public func openProfile() {
        startHomeScreen()
        tabBarController.selectedIndex = 3
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
        
        let repository = NewsRepository(
            firebaseClient: firebaseClient,
            authService: authService,
            swiftDataManager: swiftDataManager
        )
        let viewModel = NewsViewModel(audioPlayer: audioPlayer, repository: repository)
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
                    self?.openAddPostScreen()
                case .openUserProfile(id: let id):
                    self?.openProfileScreen(id: id, nvc: nvc)
                case .commentTapped(id: let id):
                    self?.openPostScreen(id: id, nvc: nvc, animated: true)
                case .shareTapped(id: let id):
                    self?.showSharePostViewController(id: id)
                }
            }
            .store(in: &setCancelable)
        return nvc
    }
    
    func makeFamilyViewController() -> UIViewController {
                
        let repository = FamilyRepository(firebaseClient: firebaseClient, authService: authService, swiftDataManager: swiftDataManager)
        let viewModel = FamilyViewModel(repository: repository)
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
        let repository = MapRepository(
            firebaseClient: firebaseClient,
            authService: authService,
            swiftDataManager: swiftDataManager
        )
        let viewModel = MapViewModel(repository: repository)
        let viewController = MapViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarMapTitle
        
        let nvc = UINavigationController(rootViewController: viewController)
        viewController.tabBarItem = appDesignSystem.components.mapTabBarItem
        return nvc
    }
    
    func makeProfileViewController() -> UIViewController {
        guard let userId = authService.account?.id else { return UIViewController() }
        let repository = ProfileRepository(
            firebaseClient: firebaseClient,
            authService: authService,
            swiftDataManager: swiftDataManager
        )
        let viewModel = ProfileViewModel(userId: userId, audioPlayer: audioPlayer, repository: repository)
        let viewController = ProfileViewController(viewModel: viewModel)
        
        let nvc = UINavigationController(rootViewController: viewController)
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .commentTapped(id: let id):
                    openPostScreen(id: id, nvc: nvc, animated: true)
                case .shareTapped(id: let id):
                    showSharePostViewController(id: id)
                case .signOut:
                    eventSubject.send(.signOut)
                case .editProfile:
                    openEditProfileScreen()
                }
            }
            .store(in: &setCancelable)
        
        viewController.tabBarItem = appDesignSystem.components.profileTabBarItem
        nvc.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        viewController.navigationItem.backButtonTitle = ""
        viewController.title = appDesignSystem.strings.tabBarProfileTitle
        return nvc
    }
    
    private func openProfileScreen(id: Int, nvc: UINavigationController) {
        let repository = ProfileRepository(
            firebaseClient: firebaseClient,
            authService: authService,
            swiftDataManager: swiftDataManager
        )
        let viewModel = ProfileViewModel(userId: id, audioPlayer: self.audioPlayer, repository: repository)
        let viewController = ProfileViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.tabBarProfileTitle
        viewController.navigationItem.backButtonTitle = ""
        nvc.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .commentTapped(id: let id) :
                    openPostScreen(id: id, nvc: nvc, animated: true)
                case .shareTapped(id: let id):
                    showSharePostViewController(id: id)
                case .signOut:
                    eventSubject.send(.signOut)
                case .editProfile:
                    openEditProfileScreen()
                }
            }
            .store(in: &setCancelable)
        
        nvc.pushViewController(viewController, animated: true)
    }
    
    private func openAddPostScreen() {
        let repository = AddPostRepository(firebaseClient: firebaseClient, authService: authService)
        let viewModel = AddPostViewModel(repository: repository)
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .addedPost:
                    self.startHomeScreen()
                }
            }
            .store(in: &setCancelable)
        
        let viewController = AddPostViewController(viewModel: viewModel)
        viewController.navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        navigationController?.isNavigationBarHidden = false
        viewController.title = appDesignSystem.strings.postScreenTitle
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func openEditProfileScreen() {
        let repository = EditProfileRepository(firebaseClient: firebaseClient, authService: authService)
        let viewModel = EditProfileViewModel(repository: repository)

        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .saveTapped:
                    start()
                    tabBarController.selectedIndex = 3
                case .viewWillDisapear:
                    self.navigationController?.isNavigationBarHidden = true
                case .onBack:
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &setCancelable)
        
        let viewController = EditProfileViewController(viewModel: viewModel)
        viewController.navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        viewController.title = appDesignSystem.strings.editProfileScreenTitle
        navigationController?.pushViewController(viewController, animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func openPostScreen(id: String, nvc: UINavigationController, animated: Bool) {
        let repository = PostRepository(
            firebaseClient: firebaseClient,
            authService: authService,
            swiftDataManager: swiftDataManager
        )
        let viewModel = PostViewModel(postId: id, audioPlayer: self.audioPlayer, repository: repository)
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .personCardTapped(id: let id):
                    openProfileScreen(id: id, nvc: nvc)
                case .shareTapped(id: let id):
                    showSharePostViewController(id: id)
                }
            }
            .store(in: &setCancelable)
        
        let viewController = PostViewController(viewModel: viewModel)
        viewController.navigationItem.backButtonTitle = ""
        nvc.navigationBar.tintColor = appDesignSystem.colors.backgroundSecondaryVariant
        viewController.title = appDesignSystem.strings.postScreenTitle
        nvc.pushViewController(viewController, animated: animated)
    }
    
    private func showSharePostViewController(id: String) {
        guard let nvc = self.navigationController else { return }
        let text = sharePostDeeplinkBody + id
        
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = nvc.view
        nvc.present(activityViewController, animated: true, completion: nil)
    }
}
