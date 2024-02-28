//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppBaseFlow

public enum BuildType: String {
    case debug

    // IMPROVE: Investigate if it's possible to adjust this via config
    case qa // exeption case for enum swiftlint:disable:this identifier_name
    case production
    case unknown
}

public struct Env {

    public var stagingApi: String { InfoPlist.apiStaging }
    public var productionApi: String { InfoPlist.apiProduction }

    private var currentApi: String {
        debugStorage.primitiveValue(
            forKey: GlobalConfig.Keys.currentApiBaseUrl
        ) ?? stagingApi
        // IMPLEMENT: Explicit setting stage api
    }

    private let debugStorage: DefaultsStorage

    public init(debugStorage: DefaultsStorage) {
        self.debugStorage = debugStorage
    }

    public var apiBaseUrlString: String {
        buildType == .production ? productionApi : currentApi
    }

    public var buildType: BuildType {
        BuildType(rawValue: InfoPlist.buildType) ?? .unknown
    }
}

extension Env: CustomStringConvertible {
    public var description: String {
        """
        {
                Version: \(InfoPlist.appVersion),
                API: \(apiBaseUrlString),
                buildType: \(buildType.rawValue)
        }
        """
    }
}

public struct InfoPlist {

    private static var info: [String: Any] { Bundle.main.infoDictionary ?? [:] }

    public static var appVersion: String {
        info["CFBundleShortVersionString"] as? String ?? ""
    }

    public static var buildType: String {
        info["BuildType"] as? String ?? ""
    }

    public static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }

    public static var apiStaging: String {
        info["APP_API_STAGING"] as? String ?? ""
    }

    public static var apiProduction: String {
        info["APP_API_PRODUCTION"] as? String ?? ""
    }
}
