//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import os.log

public enum LogLevelTag: String {
    case info = "🔵 INFO"
    case debug = "🟢 DEBUG"
    case warning = "⚠️ WARNING"
    case error = "🔴 ERROR"
    case `default` = "🟣 DEFAULT"
}

public struct LoggerConfig {
    public let subsystemName: String
    public let subsystemId: String
    public let category: String

    public init(subsystemName: String, subsystemId: String, category: String) {
        self.subsystemName = subsystemName
        self.subsystemId = subsystemId
        self.category = category
    }
}

public struct OSLogger {

    private let logWritter: OSLogWritter = .init()

    private let configuredOsLog: OSLog
    private var enabled = true

    private var osLog: OSLog {
        enabled ? configuredOsLog : .disabled
    }

    public init(config: LoggerConfig) {
        self.configuredOsLog = OSLog(
            subsystem: config.subsystemId,
            category: " \(config.subsystemName) / \(config.category) "
        )
    }

    public func info(message: String) {
        logWritter.write(osLog, level: .info, message: message)
    }

    public func debug(message: String) {
        logWritter.write(osLog, level: .debug, message: message)
    }

    public func warning(message: String) {
        logWritter.write(osLog, level: .warning, message: message)
    }

    public func error(message: String) {
        logWritter.write(osLog, level: .error, message: message)
    }
}

private struct OSLogWritter {

    func write(_ osLog: OSLog, level: LogLevelTag, message: String) {
        let osLogType: OSLogType = {
            switch level {
            case .info: return .info
            case .debug: return .debug
            case .warning: return .debug
            case .error: return .error
            case .default: return .default
            }
        }()

        write(osLog, type: osLogType, tag: level.rawValue, message: message)
    }

    private func write(_ osLog: OSLog, type: OSLogType, tag: String, message: String) {
        let logMessage = "\(tag) \(message)"

        os_log("%@", log: osLog, type: type, logMessage)
    }
}
