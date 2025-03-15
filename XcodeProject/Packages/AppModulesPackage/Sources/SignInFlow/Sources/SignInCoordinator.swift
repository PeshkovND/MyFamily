//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import AppEntities
import AppServices
import AppDesignSystem
import AppBaseFlow

public final class SignInCoordinator: EventCoordinator {
    
    public enum ScreenType {
        case signIn
        case addFamily
        case familyChecking
    }

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

    private let authService: AuthService
    private let firebaseClient: FirebaseClient
    private var designSystem = appDesignSystem

    private weak var navigationController: UINavigationController?

    public init(navigationController: UINavigationController, authService: AuthService, firebaseClient: FirebaseClient) {
        self.navigationController = navigationController
        self.authService = authService
        self.firebaseClient = firebaseClient
    }

    public func start() {
        startSignInScreen()
    }
    
    public func start(screenType: ScreenType) {
        switch screenType {
        case .signIn:
            startSignInScreen()
        case .addFamily:
            startAddFamilyForkScreen()
        case .familyChecking:
            startFamilyCheckingScreen()
        }
    }
}

// MARK: - Starting Screens

private extension SignInCoordinator {

    private func startSignInScreen(animated: Bool = true) {
        let viewModel = SignInViewModel(authService: authService)
        let viewController = SignInViewController(viewModel: viewModel)

        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .signedIn:
                    if authService.hasFilledProfile {
                        self.eventSubject.send(.finish(authState: .fullfilled))
                    } else {
                        setCancelable = []
                        startAddFamilyForkScreen(animated: false)
                    }
                case .back: self.eventSubject.send(.exit)
                }
            }
            .store(in: &setCancelable)

        navigationController?.setViewControllers([viewController], animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func startAddFamilyForkScreen(animated: Bool = true) {
        let viewModel = AddFamilyForkViewModel(authService: authService)
        let viewController = AddFamilyForkViewController(viewModel: viewModel)
        viewController.title = appDesignSystem.strings.commonSignIn

        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .openAddNewFamilyScreen:
                    startAddFamilyScreen()
                case .openEnterExistingFamilyScreen:
                    break
                case .logOut:
                    self.authService.logout(
                        onSuccess: {
                            self.startSignInScreen(animated: false)
                        },
                        onFailure: { }
                    )
                }
            }
            .store(in: &setCancelable)

        navigationController?.setViewControllers([viewController], animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func startAddFamilyScreen() {
        let repository = AddFamilyRepository(firebaseClient: firebaseClient, authService: authService)
        let viewModel = AddFamilyViewModel(repository: repository)
        let viewController = AddFamilyViewController(viewModel: viewModel)
        
        viewModel.outputEventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .familyCreated:
                    self.eventSubject.send(.finish(authState: .fullfilled))
                case .back: startAddFamilyForkScreen(animated: false)
                }
            }
            .store(in: &setCancelable)
        
        navigationController?.setViewControllers([viewController], animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func startFamilyCheckingScreen() {
        let repository = FamilyCheckingRepository(firebaseClient: firebaseClient, authService: authService)
        let viewModel = FamilyCheckingViewModel(repository: repository)
        let screen = FamilyCheckingViewController(viewModel: viewModel)
        
        viewModel.outputEventPublisher.sink { [weak self] event in
            switch event {
            case .familyFound:
                self?.eventSubject.send(.finish(authState: .fullfilled))
            case .familyNotFound:
                self?.setCancelable = []
                self?.startAddFamilyForkScreen()
            }
        }
        .store(in: &setCancelable)
        
        navigationController?.setViewControllers([screen], animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
