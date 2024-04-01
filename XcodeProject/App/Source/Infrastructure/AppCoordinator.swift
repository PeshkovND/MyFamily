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
import AppDesignSystem

final class AppCoordinator: BaseCoordinator, Coordinator {

    private static var logger = LoggerFactory.default

    private let navigationController: UINavigationController = .init()
    private var window: UIWindow?

    // Dependencies
    private let debugTogglesHolder = AppContainer.provideDebugTogglesHolder()
    private let env: Env = AppContainer.provideEnv()
    private let debugStorage = AppContainer.provideDebugDefaultsStorage()
    private let defaultsStorage = AppContainer.provideDefaultsStorage()
    private let audioPlayer = AppContainer.provideAudioPlayer()
    private var authService = AppContainer.provideAuthService()
    private lazy var logoutNotifier: LogoutNotifier = authService
    private var accountHolder: AccountHolder { authService }
    private let firebaseClient = AppContainer.provideFirebaseClinet()
    private let swiftDataManager = AppContainer.provideSwiftDataManager()
    private var timer: DispatchSourceTimer?

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
        guard self.window == nil else { return }
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
        registerShortcuts(isAuthorized: true)
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
        registerShortcuts(isAuthorized: false)
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
        observeUserStatus()
        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            authService: authService,
            debugTogglesHolder: debugTogglesHolder,
            audioPlayer: audioPlayer,
            firebaseClient: firebaseClient, 
            swiftDataManager: swiftDataManager
        )
        let token = coordinator.events.sink { event in
            switch event {
            case .finished:
                break
            case .signOut:
                self.authService.logout(
                    onSuccess: { self.startSignInFlow() },
                    onFailure: { }
                )
                
            }
        }
        addDependency(coordinator, token: token)
        
        switch Deeplinker.deeplinkType {
        case .post(id: let id):
            coordinator.openPost(id: id)
        case .news:
            coordinator.openNews()
        case .family:
            coordinator.openFamily()
        case .map:
            coordinator.openMap()
        case .profile:
            coordinator.openProfile()
            
        default:
            coordinator.start()
        }
        Deeplinker.deeplinkType = nil
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
    
    private func observeUserStatus() {
        let queue = DispatchQueue(label: "com.domain.app.timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        guard let timer = self.timer else { return }
        timer.schedule(deadline: .now(), repeating: .seconds(300))
        timer.setEventHandler {
            Task {
                let currentDate = Date()
                let calendar = Calendar.current
                var dateComponents = DateComponents()
                dateComponents.minute = 5
                guard
                    let newDate = calendar.date(byAdding: dateComponents, to: currentDate),
                    let userId = self.authService.account?.id
                else { return }
                let dateFormatter = AppDateFormatter()
                let dateString = dateFormatter.toString(newDate)
                
                let userStatus = UserStatus(
                    userId: userId,
                    lastOnline: dateString,
                    position: Position(lat: 0.0, lng: 0.0)
                )
                try await self.firebaseClient.setUserStatus(userStatus)
            }
        }
        timer.resume()
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
    
    // swiftlint:disable function_body_length
    private func registerShortcuts(isAuthorized: Bool) {
        guard isAuthorized else {
            UIApplication.shared.shortcutItems = []
            return
        }
        
        let newsIcon = UIApplicationShortcutIcon(systemImageName: "house")
        let newsShortcutItem = UIApplicationShortcutItem(
            type: ShortcutKey.news.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarNewsTitle,
            localizedSubtitle: nil,
            icon: newsIcon,
            userInfo: nil
        )
        
        let mapIcon = UIApplicationShortcutIcon(systemImageName: "map")
        let mapShortcutItem = UIApplicationShortcutItem(
            type: ShortcutKey.map.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarMapTitle,
            localizedSubtitle: nil,
            icon: mapIcon,
            userInfo: nil
        )
        
        let familyIcon = UIApplicationShortcutIcon(systemImageName: "figure.2.and.child.holdinghands")
        let familyShortcutItem = UIApplicationShortcutItem(
            type: ShortcutKey.family.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarFamilyTitle,
            localizedSubtitle: nil,
            icon: familyIcon,
            userInfo: nil
        )
        
        let profileIcon = UIApplicationShortcutIcon(systemImageName: "person.crop.circle")
        let profileShortcutItem = UIApplicationShortcutItem(
            type: ShortcutKey.profile.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarProfileTitle,
            localizedSubtitle: nil,
            icon: profileIcon,
            userInfo: nil
        )
        
        UIApplication.shared.shortcutItems = [
            newsShortcutItem,
            familyShortcutItem,
            mapShortcutItem,
            profileShortcutItem
        ]
    }
}
