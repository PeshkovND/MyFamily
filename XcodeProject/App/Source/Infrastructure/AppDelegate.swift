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
        Messaging.messaging().subscribe(toTopic: "newPost") { _ in
          print("Subscribing error")
        }
    }
        
    func configureFirebaseMessaging(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        let authOptions: UNAuthorizationOptions = [ .alert, .badge, .sound ]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        application.registerForRemoteNotifications()
    }
}
