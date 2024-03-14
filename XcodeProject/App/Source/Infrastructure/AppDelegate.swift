//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Utilities
import AppServices

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private static var logger = LoggerFactory.default

    private let appCoordinator = AppContainer.provideAppCoordinator()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        initializeStartupServices()
        appCoordinator.start()

        logApplicationStartedEvent()

        return true
    }

    private func initializeStartupServices() {
        ImageLoadingHelper.enableWebPCoder()
        KeyboardHealper.firstEnableKeyboardManager()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
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
