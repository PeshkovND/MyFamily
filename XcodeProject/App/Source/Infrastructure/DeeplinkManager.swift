import Foundation
import UIKit
import AppDesignSystem

enum DeeplinkType {
    case post(id: String)
    case news
    case family
    case map
    case profile
}

let Deeplinker = DeepLinkManager()

final class DeepLinkManager {
    fileprivate init() {}
    var deeplinkType: DeeplinkType?
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
    }
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deeplinkType = ShortcutParser.shared.handleShortcut(item)
        return deeplinkType != nil
    }
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
       deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
}

final class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private let appCoordinator = AppContainer.provideAppCoordinator()
    private init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        default:
            appCoordinator.start()
        }
    }
}

final class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        switch host {
        case "post":
            if let postId = pathComponents.first {
                return DeeplinkType.post(id: postId)
            }
        default:
            break
        }
        return nil
    }
}

final class ShortcutParser {
    static let shared = ShortcutParser()
    private init() { }
    
    func handleShortcut(_ shortcut: UIApplicationShortcutItem) -> DeeplinkType? {
       switch shortcut.type {
       case ShortcutKey.news.rawValue:
           return .news
       case ShortcutKey.family.rawValue:
           return .family
       case ShortcutKey.map.rawValue:
           return .map
       case ShortcutKey.profile.rawValue:
          return .profile
       default:
          return nil
       }
    }
}

final class NotificationParser {
   static let shared = NotificationParser()
    
   private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeeplinkType? {
        if let postId = userInfo["postId"] as? String {
            return DeeplinkType.post(id: postId)
        }
        return nil
    }
}

enum ShortcutKey: String {
    case news = "com.myApp.news"
    case family = "com.myApp.family"
    case map = "com.myApp.map"
    case profile = "com.myApp.profile"
}
