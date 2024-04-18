import Foundation
import UIKit
import AppDesignSystem

public class ShortcutMaker {
     private static let newsShortcutItem: UIApplicationShortcutItem = {
        let newsIcon = UIApplicationShortcutIcon(systemImageName: "house")
        return UIApplicationShortcutItem(
            type: ShortcutKey.news.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarNewsTitle,
            localizedSubtitle: nil,
            icon: newsIcon,
            userInfo: nil
        )
    }()
    
    private static let mapShortcutItem: UIApplicationShortcutItem = {
        let mapIcon = UIApplicationShortcutIcon(systemImageName: "map")
        return UIApplicationShortcutItem(
            type: ShortcutKey.map.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarMapTitle,
            localizedSubtitle: nil,
            icon: mapIcon,
            userInfo: nil
        )
    }()
    
    private static let familyShortcutItem: UIApplicationShortcutItem = {
        let familyIcon = UIApplicationShortcutIcon(systemImageName: "figure.2.and.child.holdinghands")
        return UIApplicationShortcutItem(
            type: ShortcutKey.family.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarFamilyTitle,
            localizedSubtitle: nil,
            icon: familyIcon,
            userInfo: nil
        )
    }()
    
    private static let profileShortcutItem: UIApplicationShortcutItem = {
        let profileIcon = UIApplicationShortcutIcon(systemImageName: "person.crop.circle")
        return UIApplicationShortcutItem(
            type: ShortcutKey.profile.rawValue,
            localizedTitle: appDesignSystem.strings.tabBarProfileTitle,
            localizedSubtitle: nil,
            icon: profileIcon,
            userInfo: nil
        )
    }()
    
    public static func addShortcuts() {
        UIApplication.shared.shortcutItems = [
            newsShortcutItem,
            familyShortcutItem,
            mapShortcutItem,
            profileShortcutItem
        ]
    }
    
    public static func removeShortcuts() {
        UIApplication.shared.shortcutItems = []
    }
}
