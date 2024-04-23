//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public struct IconsLibrary: SafeResource {

    var stub: UIImage { .init() }

    init() {}

    private func valueOrStub(_ image: UIImage?) -> UIImage {
        return image ?? stub
    }
}

// MARK: - App Icons

extension IconsLibrary {
    public var homeTabbarExplore: UIImage { valueOrStub("home_tabbar_explore") }
    public var homeTabbarStore: UIImage { valueOrStub("home_tabbar_store") }
    public var homeTabbarProfile: UIImage { valueOrStub("home_tabbar_profile") }
    
    public var signInBackground: UIImage { valueOrStub("SignInBackground") }
    public var profileBackground: UIImage { valueOrStub("ProfileBackground") }
    public var vkLogo: UIImage { valueOrStub("vk_logo") }
    
    public var like: UIImage { valueOrStub(UIImage(systemName: "heart")) }
    public var likeFilled: UIImage { valueOrStub(UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)) }
    public var comment: UIImage { valueOrStub(UIImage(systemName: "message")) }
    public var share: UIImage { valueOrStub(UIImage(systemName: "paperplane")) }
    
    public var premium: UIImage { valueOrStub(UIImage(systemName: "crown")?.withTintColor(appDesignSystem.colors.premiumColor)) }
    
    public var play: UIImage { valueOrStub(UIImage(systemName: "play")?.withTintColor(.white, renderingMode: .alwaysOriginal)) }
    public var pause: UIImage { valueOrStub(UIImage(systemName: "pause")?.withTintColor(.white, renderingMode: .alwaysOriginal)) }
    
    public var map: UIImage { valueOrStub(UIImage(systemName: "map")) }
    public var home: UIImage { valueOrStub(UIImage(systemName: "house")) }
    public var homeFill: UIImage {
        valueOrStub(UIImage(systemName: "house.fill")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var family: UIImage { valueOrStub(UIImage(systemName: "figure.2.and.child.holdinghands")) }
    public var profile: UIImage { valueOrStub(UIImage(systemName: "person.crop.circle")) }
    
    public var error: UIImage { valueOrStub(UIImage(systemName: "exclamationmark.triangle")?.withTintColor(.red)) }
    
    public var camera: UIImage {
        valueOrStub(UIImage(systemName: "camera")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var gallery: UIImage {
        valueOrStub(UIImage(systemName: "photo.on.rectangle")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var videoGallery: UIImage {
        valueOrStub(UIImage(systemName: "arrow.up.right.video")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    
    public var sendIcon: UIImage {
        valueOrStub(UIImage(systemName: "arrow.forward.circle")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var closeFill: UIImage {
        valueOrStub(UIImage(systemName: "x.circle.fill")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var close: UIImage {
        valueOrStub(UIImage(systemName: "xmark")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }

    public var photo: UIImage {
        valueOrStub(UIImage(systemName: "photo")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var video: UIImage {
        valueOrStub(UIImage(systemName: "video")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var microphone: UIImage {
        valueOrStub(UIImage(systemName: "mic")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var music: UIImage {
        valueOrStub(UIImage(systemName: "music.note")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var stopRecording: UIImage {
        valueOrStub(UIImage(systemName: "stop.circle")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    
    public var addPhoto: UIImage { valueOrStub(UIImage(systemName: "photo.badge.plus")?.withTintColor(.white, renderingMode: .alwaysOriginal)) }
    
    public var houseInCircle: UIImage {
        valueOrStub(UIImage(systemName: "house.circle.fill")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    
    public var location: UIImage {
        valueOrStub(UIImage(systemName: "location.fill")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    
    public var plus: UIImage {
        valueOrStub(UIImage(systemName: "plus")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        )) }
    
    public var door: UIImage {
        valueOrStub(UIImage(systemName: "door.left.hand.open")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var pencil: UIImage {
        valueOrStub(UIImage(systemName: "pencil")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    public var setting: UIImage {
        valueOrStub(UIImage(systemName: "gearshape")?.withTintColor(
            appDesignSystem.colors.backgroundSecondaryVariant,
            renderingMode: .alwaysOriginal
        ))
    }
    
}

// SFSymbols Example

extension IconsLibrary {
    
    public var plusInCircle: UIImage {
        let configuration = UIImage.SymbolConfiguration(
            weight: .medium
        )
        let image = UIImage(
            systemName: "plus.circle",
            withConfiguration: configuration
        )
        return valueOrStub(image)
    }

    public var chevronRight: UIImage {
        let configuration = UIImage.SymbolConfiguration(weight: .medium)
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: configuration
        )
        return valueOrStub(image)
    }
}
