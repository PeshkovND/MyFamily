//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Utilities

// MARK: - Logger

public protocol Logger {

    func info(message: String)
    func debug(message: String)
    func warning(message: String)
    func error(message: String)
}

// MARK: - Logger Helpers

public extension Logger {

    func error(_ error: Error) {
        self.error(message: error.localizedDescription)
    }
}

// MARK: - OSLogger + Logger
extension OSLogger: Logger {}

public struct StubLogger: Logger {

    init() {}

    public func info(message: String) {}
    public func debug(message: String) {}
    public func warning(message: String) {}
    public func error(message: String) {}
}

public struct LoggerFactory {

    public static var `default`: Logger { OSLogger(config: .default) }

    public static func make(config: LoggerConfig) -> Logger {
        OSLogger(config: config)
    }

    public static func makeStub() -> Logger {
        StubLogger()
    }

    private init() {}
}

// MARK: - LoggerConfig + Default

public extension LoggerConfig {

    private static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "undefined"
    }

    static var `default`: LoggerConfig = .init(
        subsystemName: "App",
        subsystemId: bundleId,
        category: "Default"
    )
}
