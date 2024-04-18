//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Utilities
import AppServices
import FirebaseCore
import AVFoundation
import BackgroundTasks
import FirebaseMessaging

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private static var logger = LoggerFactory.default

    private let firebaseClient = AppContainer.provideFirebaseClinet()
    private let locationManager = AppContainer.provideLocationManager()
    private let authService = AppContainer.provideAuthService()
    private let appCoordinator = AppContainer.provideAppCoordinator()
    private let taskId = "com.background.geolocation"
    

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        BGTaskScheduler.shared.register(forTaskWithIdentifier: self.taskId, using: DispatchQueue.global()) { task in
            guard let task = task as? BGProcessingTask else { return }
            self.handleTask(task: task)
        }
        
        initializeStartupServices()
        configureFirebaseMessaging(application: application)
        scheduleNewTask()
        appCoordinator.start()

        logApplicationStartedEvent()

        return true
    }
    
    // swiftlint:disable function_body_length
    private func handleTask(task: BGProcessingTask) {
        // swiftlint:disable closure_body_length
        let fetchTask = Task {
            guard let user = authService.account else {
                task.setTaskCompleted(success: false)
                return
            }
            let locationMAnager = AppContainer.provideLocationManager()
            // swiftlint:disable closure_body_length
            locationMAnager.outputEventPublisher.sink { event in
                switch event {
                case .observationStarted:
                    Task {
                        do {
                            guard let coordinates = self.locationManager.lastLocation else { task.setTaskCompleted(success: false)
                                self.scheduleNewTask()
                                return
                            }
                            try await self.firebaseClient.setUserCoordinates(
                                userId: user.id,
                                coordinates: Position(lat: coordinates.latitude, lng: coordinates.latitude)
                            )
                            task.setTaskCompleted(success: true)
                            self.scheduleNewTask()
                        } catch {
                            task.setTaskCompleted(success: false)
                            self.scheduleNewTask()
                        }
                    }
                case .locationServicesNotEnabled:
                    task.setTaskCompleted(success: false)
                    self.scheduleNewTask()
                case .checkAuthorizationFailed:
                    task.setTaskCompleted(success: false)
                    self.scheduleNewTask()
                case .didUpdateLocation(location: let location):
                    break
                }
            }
        }

        task.expirationHandler = {
            fetchTask.cancel()
        }
        
    }
    
    public func scheduleNewTask() {
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard requests.isEmpty else { return }
            
            do {
                let newTask = BGProcessingTaskRequest(identifier: self.taskId)
                newTask.earliestBeginDate = Date().addingTimeInterval(60) // Every 6 hours
                try BGTaskScheduler.shared.submit(newTask)
                print("AMOGUS")
            } catch {
                print("Could not schedule new task: \(error)")
            }
        }
    }

    private func initializeStartupServices() {
        ImageLoadingHelper.enableWebPCoder()
        KeyboardHealper.firstEnableKeyboardManager()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            print("AVAudioSessionCategoryPlayback not work")
        }
        UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
        Deeplinker.checkDeepLink()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [: ]) -> Bool {
        return Deeplinker.handleDeeplink(url: url)
    }
    
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(Deeplinker.handleShortcut(item: shortcutItem))
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleNewTask()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult
        ) -> Void
    ) {
        Deeplinker.handleRemoteNotification(userInfo)
    }
}

private extension AppDelegate {

    private func logApplicationStartedEvent() {
        Self.logger.info(
            message: "Application started! Environment: \(AppContainer.provideEnv())"
        )
    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("PUSH TOKEN: \(fcmToken)")
        Messaging.messaging().subscribe(toTopic: "newPost") { _ in }
    }
        
    func configureFirebaseMessaging(application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }
}
