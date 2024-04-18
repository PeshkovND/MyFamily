//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Utilities

public enum AppError: LocalizedError, Equatable {

    case network(causedByError: Error)
    case api(general: General, specific: [Field])
    case permissionDenied
    case undefined(causedError: Error)
    case unathorized
    case custom(title: String, message: String)

    public static var unexpected: AppError {
        .undefined(causedError: AnyLocalizedError.unexpected)
    }

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {

        case (.unathorized, .unathorized):
            return true

        case (.network(let lhsError), .network(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.undefined(let lhsError), .undefined(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription

        case (.api(let lhsGeneral, let lhsSpecific), .api(let rhsGeneral, let rhsSpecific)):
            let hasEqualedGeneralErrors = lhsGeneral == rhsGeneral
            let hasEqualSpecificErrors = lhsSpecific == rhsSpecific
            let hasEqualedErrors = hasEqualedGeneralErrors && hasEqualSpecificErrors
            return hasEqualedErrors
            
        default: return false
        }
    }
}

extension AppError {

    public struct General: Error, Equatable {
        public let code: String
        public let message: String

        public init(code: String, message: String) {
            self.code = code
            self.message = message
        }
    }

    public struct Field: Error, Equatable {
        public let field: String
        public let message: String

        public init(field: String, message: String) {
            self.field = field
            self.message = message
        }
    }

}
