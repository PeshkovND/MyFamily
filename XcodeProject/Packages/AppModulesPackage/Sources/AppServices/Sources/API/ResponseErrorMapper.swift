//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Alamofire
import Utilities
import AppEntities

struct ResponseErrorMapper {

    func makeAppError(from errorPayload: ClientErrorPayload) -> AppError {
        guard
            let code = errorPayload.code,
            let message = errorPayload.message
        else {
            let message = "Error code or message are missed in response"
            return .network(causedByError: AnyLocalizedError(failureMessage: message))
        }

        let generalError = AppError.General(code: code, message: message)
        let specificError = makeFieldErrors(from: errorPayload.validationError)

        return .api(
            general: generalError,
            specific: specificError
        )
    }

    func makeAppError(from afError: AFError) -> AppError {
        .network(causedByError: afError)
    }

    func makeFieldErrors(from validationError: ValidationErrorPayload?) -> [AppError.Field] {
        guard let validationError = validationError else { return [] }

        let detailedInfoArray: [ValidationErrorPayload.DetailedInfo] = [
            validationError.body,
            validationError.query,
            validationError.params
        ]
        .compactMap { $0 }
        .flatMap { $0 }

        let specificErrors: [AppError.Field] = detailedInfoArray.map {
            let fieldName = $0.context.label.isNotEmpty ? $0.context.label : $0.context.key
            return AppError.Field(
                field: fieldName,
                message: $0.message
            )
        }

        return specificErrors
    }
}
