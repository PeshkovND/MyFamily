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
