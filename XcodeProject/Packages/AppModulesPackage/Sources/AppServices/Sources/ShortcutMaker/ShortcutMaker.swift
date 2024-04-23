import Foundation
import UIKit
import AppDesignSystem

public class ShortcutMaker {
    private struct ShortcutInfo {
        let type: String
        let icon: UIApplicationShortcutIcon
        let title: String
    }
    
    private static let application = UIApplication.shared
    
    private static let shortcuts: [ShortcutInfo] = [
        ShortcutInfo(
            type: ShortcutKey.news.rawValue,
            icon: UIApplicationShortcutIcon(systemImageName: "house"),
            title: appDesignSystem.strings.tabBarNewsTitle
        ),
        ShortcutInfo(
            type: ShortcutKey.map.rawValue,
            icon: UIApplicationShortcutIcon(systemImageName: "map"),
            title: appDesignSystem.strings.tabBarMapTitle
        ),
        ShortcutInfo(
            type: ShortcutKey.family.rawValue,
            icon: UIApplicationShortcutIcon(systemImageName: "figure.2.and.child.holdinghands"),
            title: appDesignSystem.strings.tabBarFamilyTitle
        ),
        ShortcutInfo(
            type: ShortcutKey.profile.rawValue,
            icon: UIApplicationShortcutIcon(systemImageName: "person.crop.circle"),
            title: appDesignSystem.strings.tabBarProfileTitle
        )
    ]
    
    public static func addShortcuts() {
        application.shortcutItems = shortcuts.map { elem in
            UIApplicationShortcutItem(
                type: elem.type,
                localizedTitle: elem.title,
                localizedSubtitle: nil,
                icon: elem.icon,
                userInfo: nil
            )
        }
    }
    
    public static func removeShortcuts() {
        application.shortcutItems = []
    }
}
