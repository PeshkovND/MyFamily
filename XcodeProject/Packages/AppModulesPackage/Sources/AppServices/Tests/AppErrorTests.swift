//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import XCTest
import Utilities
import AppEntities
@testable import AppServices

final class AppErrorTests: XCTestCase {

    private var responseErrorMapper: ResponseErrorMapper = .init()

    override func setUp() {
        super.setUp()
        responseErrorMapper = .init()
    }

    func testThatResponseErrorIsMappedToAppError() {
        typealias StubPayloadType = String

        let responseError: ClientErrorPayload = .init(
            code: "1001",
            message: "Validation Error",
            validationError: .init(
                body: [
                    .init(
                        message: "\"uuid\" length must be at least 6 characters long",
                        path: ["uuid"],
                        type: "string.min",
                        context: .init(
                            limit: 6,
                            value: 123,
                            label: "uuid",
                            key: "uuid"
                        )
                    )
                ],
                params: nil,
                query: nil
            )
        )

        let appError = responseErrorMapper.makeAppError(from: responseError)

        let expectedAppError: AppError = .api(
            general: .init(
                code: "1001",
                message: "Validation Error"
            ),
            specific: [
                .init(
                    field: "uuid",
                    message: "\"uuid\" length must be at least 6 characters long"
                )
            ]
        )

        XCTAssertEqual(appError, expectedAppError)
    }

}
