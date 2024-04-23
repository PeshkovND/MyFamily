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
import CoreLocation
import BackgroundTasks

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
    private let locationManager = AppContainer.provideLocationManager()
    private let swiftDataManager = AppContainer.provideSwiftDataManager()
    private let purchaseManager = AppContainer.providePurchaseManager()
    private let deeplinker = AppContainer.provideDeeplinker()
    private let backgroundTasksManager = AppContainer.provideBackgroundTasksManager()
    private var timer: DispatchSourceTimer?
    private var setCancelable = Set<AnyCancellable>()
    
    // Debug panel for testing
    private var inAppDebugger: InAppDebugger?
    private var notificationCenter: NotificationCenter { .default }
    private var switchingEnvSubscription: AnyCancellable?
    
    private let queue = DispatchQueue(label: "com.domain.app.timer")

    func start() {
        initWindow()
        
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
        }
    }
    
    private func startHomeFlow() {
        let coordinator = HomeCoordinator(
            navigationController: navigationController,
            authService: authService,
            debugTogglesHolder: debugTogglesHolder,
            audioPlayer: audioPlayer,
            firebaseClient: firebaseClient,
            locationManager: locationManager,
            swiftDataManager: swiftDataManager,
            purchaseManager: purchaseManager,
            defaultsStorage: defaultsStorage
        )
        
        let token = coordinator.events.sink { event in
            switch event {
            case .signOut:
                self.removeAll()
                self.authService.logout(
                    onSuccess: {
                        self.startSignInFlow()
                        self.backgroundTasksManager.cancelTask(backgroundTaskId: self.env.geolocationBackgroundTaskId)
                    },
                    onFailure: { }
                )
            }
        }
        
        addDependency(coordinator, token: token)
        backgroundTasksManager.scheduleNewTask(backgroundTaskId: env.geolocationBackgroundTaskId)
        setupLocationManager()
        showHome(coordinator: coordinator)
    }
    
    private func showHome(coordinator: HomeCoordinator) {
        switch deeplinker.deeplinkType {
        case .post(id: let id):
            coordinator.startPost(id: id)
        case .news:
            coordinator.startNews()
        case .family:
            coordinator.startFamily()
        case .map:
            coordinator.startMap()
        case .profile:
            coordinator.startProfile()
        case .none:
            coordinator.start()
        }
        deeplinker.deeplinkType = nil
    }

    private func setupSendUserStatusTimer() {
        timer = DispatchSource.makeTimerSource(queue: queue)
        guard let timer = self.timer else { return }
        timer.schedule(deadline: .now(), repeating: .seconds(300))
        timer.setEventHandler {
            Task {
               try await self.updateUserStatus()
            }
        }
        timer.resume()
    }
    
    private func setupLocationManager() {
        locationManager.outputEventPublisher.sink { event in
            switch event {
            case .checkAuthorizationFailed:
                self.showAlert(title: "Error", text: "Please enable always-on location")
                self.setupSendUserStatusTimer()
            case .locationServicesNotEnabled:
                self.showAlert(title: "Error", text: "Please enable location services")
                self.setupSendUserStatusTimer()
            case .didUpdateLocation:
                break
            case .observationStarted:
                self.setupSendUserStatusTimer()
            }
        }.store(in: &setCancelable)
        locationManager.setup()
    }
    
    private func showAlert(title: String, text: String) {
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.navigationController.present(alert, animated: true)
    }
    
    private func updateUserStatus() async throws {
        guard await UIApplication.shared.applicationState == .active else { return }
        let currentDate = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.minute = 5
        guard let newDate = calendar.date(byAdding: dateComponents, to: currentDate), let userId = self.authService.account?.id else { return }
        let dateFormatter = AppDateFormatter()
        let dateString = dateFormatter.toString(newDate)
        var userStatus = UserStatus(userId: userId, lastOnline: dateString, position: Position(lat: 0, lng: 0))
        if let location = locationManager.lastLocation {
            userStatus.position = Position(lat: location.latitude, lng: location.longitude)
        } else {
            let lastUserStatusResult = try await firebaseClient.getUserStatus(userId)
            switch lastUserStatusResult {
            case .success(let lastUserStatus):
                userStatus.position = lastUserStatus.position
            case .failure:
                return
            }
        }
        try await self.firebaseClient.setUserStatus(userStatus)
    }

    private func registerShortcuts(isAuthorized: Bool) {
        if isAuthorized {
            ShortcutMaker.addShortcuts()
        } else {
            ShortcutMaker.removeShortcuts()
        }
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

private extension AppCoordinator {
    
}
