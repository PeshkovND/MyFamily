//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import AppEntities
import AppDesignSystem

public struct BaseUIError<FieldInfo> {

    public struct Alert {
        public let title: String?
        public let message: String

        public init(title: String? = nil, message: String) {
            self.title = title
            self.message = message
        }
    }

    public let alert: Alert?
    public let fieldsInfo: FieldInfo?

    public init(alert: Alert? = nil, fieldsInfo: FieldInfo? = nil) {
        self.alert = alert
        self.fieldsInfo = fieldsInfo
    }

    public static func defaultUIError(
        from appError: AppError,
        designSystem: DesignSystem = appDesignSystem
    ) -> Self? {
        let strings = appDesignSystem.strings
        switch appError {
        case .api(general: let generalError, _):
             return .init(
                alert: .init(message: generalError.localizedDescription)
            )
        case .undefined(let error):
            return .init(
                alert: .init(message: error.localizedDescription)
            )
        case .network:
            return .init(
                alert: .init(title: strings.commonError, message: strings.commonErrorNetwork)
            )
        case .unexpected:
            return .init(
                alert: .init(
                    title: strings.commonError, message: strings.commonUnexpectedError
                )
            )
        case .custom(let title, let message):
            return .init(
                alert: .init(
                    title: title, message: message
                )
            )
        case .permissionDenied, .unathorized:
            // INFO: It's not supposed to handle it by default
            return nil
        }
    }

    public static var stub: BaseUIError<String> {
        .init(
            alert: .init(title: "Stub error", message: "Opps, Something went wrong!"),
            fieldsInfo: "Validation failed."
        )
    }
}
