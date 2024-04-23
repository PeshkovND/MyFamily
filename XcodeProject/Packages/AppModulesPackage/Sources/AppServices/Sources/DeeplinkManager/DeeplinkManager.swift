import Foundation
import UIKit
import AppDesignSystem
import AppBaseFlow

public enum DeeplinkType {
    case post(id: String)
    case news
    case family
    case map
    case profile
}

enum ShortcutKey: String {
    case news = "com.myApp.news"
    case family = "com.myApp.family"
    case map = "com.myApp.map"
    case profile = "com.myApp.profile"
}

public final class DeepLinkManager {
    public init() {}
    public var deeplinkType: DeeplinkType?
    
    private let deeplinkNavigator = DeeplinkNavigator()
    
    private let notificationParser = NotificationParser()
    private let deeplinkParser = DeeplinkParser()
    private let shortcutParser = ShortcutParser()

    public func checkDeepLink(coordinator: Coordinator) {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        deeplinkNavigator.proceedToDeeplink(deeplinkType, coordinator: coordinator)
    }
    
    @discardableResult
    public func handleDeeplink(url: URL) -> Bool {
        deeplinkType = deeplinkParser.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    public func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deeplinkType = shortcutParser.handleShortcut(item)
        return deeplinkType != nil
    }
    
    public func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = notificationParser.handleNotification(notification)
    }
}

private final class DeeplinkNavigator {
    fileprivate init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType, coordinator: Coordinator) {
        switch type {
        default:
            coordinator.start()
        }
    }
}

private final class DeeplinkParser {
    fileprivate init() { }
    
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

private final class ShortcutParser {
    fileprivate init() { }
    
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

private final class NotificationParser {
    fileprivate init() { }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) -> DeeplinkType? {
        if let postId = userInfo["postId"] as? String {
            return DeeplinkType.post(id: postId)
        }
        return nil
    }
}
