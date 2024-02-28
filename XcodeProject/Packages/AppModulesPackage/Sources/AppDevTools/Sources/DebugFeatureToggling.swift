//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices

public final class DebugTogglesHolder {

    public enum FeatureFlags: String, CaseIterable {
        case isOnboardingFeatureEnabled
        case isUserProfileFeatureEnabled
    }

    private let debugStorage: DefaultsStorage

    public init(debugStorage: DefaultsStorage) {
        self.debugStorage = debugStorage
    }

    public func toggleValue(for key: FeatureFlags) -> Bool {
        debugStorage.primitiveValue(forKey: key.rawValue) ?? false
    }

    public func putValue(value: Bool, for key: FeatureFlags) {
        debugStorage.add(primitiveValue: value, forKey: key.rawValue)
    }
}
