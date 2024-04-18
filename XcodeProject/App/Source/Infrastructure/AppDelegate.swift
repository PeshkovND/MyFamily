//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Utilities
import AppServices
import FirebaseCore
import AVFoundation
import FirebaseMessaging

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private static var logger = LoggerFactory.default

    private let appCoordinator = AppContainer.provideAppCoordinator()
    private let deeplinker = AppContainer.provideDeeplinker()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        initializeStartupServices()
        configureFirebaseMessaging(application: application)
        appCoordinator.start()

        logApplicationStartedEvent()
        return true
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
        deeplinker.checkDeepLink(coordinator: appCoordinator)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [: ]) -> Bool {
        return deeplinker.handleDeeplink(url: url)
    }
    
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(deeplinker.handleShortcut(item: shortcutItem))
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
        deeplinker.handleRemoteNotification(userInfo)
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
