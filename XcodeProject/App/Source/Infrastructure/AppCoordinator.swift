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
    private var timer: DispatchSourceTimer?
    
    // Debug panel for testing
    private var inAppDebugger: InAppDebugger?
    private var notificationCenter: NotificationCenter { .default }
    private var switchingEnvSubscription: AnyCancellable?
    
    private var setCancelable = Set<AnyCancellable>()
    
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
    
    // swiftlint:disable function_body_length
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
            case .finished:
                break
            case .signOut:
                self.authService.logout(
                    onSuccess: { 
                        self.startSignInFlow()
                        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: self.backgroundTaskId)
                    },
                    onFailure: { }
                )
            }
        }
        
        addDependency(coordinator, token: token)
        registerTask(taskId: backgroundTaskId)
        scheduleNewTask()
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
        case .none:
            coordinator.start()
        }
        
        Deeplinker.deeplinkType = nil
        observeUserStatus()
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
        locationManager.outputEventPublisher.sink { event in
            switch event {
            case .checkAuthorizationFailed:
                self.showAlert(title: "Error", text: "Please enable always-on location")
                self.sendUserStatus()
            case .locationServicesNotEnabled:
                self.showAlert(title: "Error", text: "Please enable location services")
                self.sendUserStatus()
            case .didUpdateLocation(location: let location):
                break
            case .observationStarted:
                self.sendUserStatus()
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
    
    private func sendUserStatus() {
        let queue = DispatchQueue(label: "com.domain.app.timer")
        self.timer = DispatchSource.makeTimerSource(queue: queue)
        guard let timer = self.timer else { return }
        timer.schedule(deadline: .now(), repeating: .seconds(300))
        timer.setEventHandler {
            self.sendUserStatusTask()
        }
        timer.resume()
    }
    
    // swiftlint:disable closure_body_length
    private func sendUserStatusTask() {
        Task {
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

private extension AppCoordinator {
    private var backgroundTaskId: String { "com.background.geolocation" }
    
    private func scheduleNewTask() {
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard requests.isEmpty else { return }
            
            do {
                let newTask = BGProcessingTaskRequest(identifier: self.backgroundTaskId)
                try BGTaskScheduler.shared.submit(newTask)
            } catch {
                print("Could not schedule new task: \(error)")
            }
        }
    }
    
    private func registerTask(taskId: String) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskId, using: DispatchQueue.global()) { task in
            guard let task = task as? BGProcessingTask else { return }
            self.handleTask(task: task)
        }
    }
    
    private func handleTask(task: BGProcessingTask) {
        // swiftlint:disable closure_body_length
        let fetchTask = Task {
            defer {
                scheduleNewTask()
            }
            
            let count = UserDefaults.standard.integer(forKey: "teeest") + 1
            UserDefaults.standard.set(count, forKey: "teeest")
            print(count)
            let locationManager = AppContainer.provideLocationManager()
            locationManager.setup()
            guard
                let user = authService.account,
                let location = locationManager.lastLocation
            else {
                task.setTaskCompleted(success: false)
                return
            }
            do {
                try await self.firebaseClient.setUserCoordinates(
                    userId: user.id,
                    coordinates: Position(lat: location.latitude, lng: location.longitude)
                )
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
                return
            }
        }
        
        task.expirationHandler = {
            fetchTask.cancel()
            task.setTaskCompleted(success: false)
            self.scheduleNewTask()
        }
    }
}
