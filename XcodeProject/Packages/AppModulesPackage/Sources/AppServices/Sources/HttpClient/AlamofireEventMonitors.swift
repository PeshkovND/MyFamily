//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Alamofire

// MARK: - Request Logger

public final class RequestLogEventMonitor: EventMonitor {

    private static var logger: Logger { LoggerFactory.default }

    public let queue: DispatchQueue

    public init(queue: DispatchQueue) {
        self.queue = queue
    }

    public func requestDidResume(_ request: Request) {
        queue.async {
            let message =
            """

                    Network Request ↗️

                cURL
            ----------------------------------------------------------
            \(request.cURLDescription())
            ----------------------------------------------------------
            """
            Self.logger.debug(message: message)
        }
    }
}

// MARK: - Response Logger

public final class ResponseLogEventMonitor: EventMonitor {

    private static var logger: Logger { LoggerFactory.default }

    public let queue: DispatchQueue

    public init(queue: DispatchQueue) {
        self.queue = queue
    }

    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        queue.async {
            Self.logger.debug(message: self.makeResponeLogMessage(response: response))
        }
    }

    private func makeResponeLogMessage<Value>(
        response: DataResponse<Value, AFError>
    ) -> String {

        let extraErrorMessage: String = {
            guard let error = response.error else { return "" }
            let message = "\nExtra: \(error.localizedDescription)"
            return message
        }()

        let statusCode = response.response?.statusCode ?? 0
        let responseStatus = statusCode < 400 ? "✅" : "❌"

        let message =
        """

                Network Response ↘️

        ----------------------------------------------------------
        URL: \(response.request?.url?.absoluteString ?? "undefined")
        Status Code: \(response.response?.statusCode ?? 0)
        ----------------------------------------------------------

            Response \(responseStatus)
        ==========================================================
        \(response.data?.prettyPrintedString ?? "Empty response")
        \(extraErrorMessage)
        ==========================================================
        """

        return message
    }
}
