//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import XCTest
import Utilities
@testable import AppServices

final class ErrorHttpResponseTests: XCTestCase {

    private var jsonDecoder: JSONDecoder = .init()

    private var errorHttpResponseJsonFile: String {
        "error_http_response.json"
    }

    private var testBundle: Bundle {
        .module
    }

    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder()
    }

    func testThatErrorResponseDecodedFromJsonFile() throws {
        typealias StubPayloadType = String

        let jsonData = try XCTUnwrap(
            JsonFileLoader.loadData(from: errorHttpResponseJsonFile, bundle: testBundle)
        )

        let errorResponse = try XCTUnwrap(
            try? jsonDecoder.decode(
                HttpResponse<StubPayloadType>.self,
                from: jsonData
            )
        )

        let expectedResponseError: HttpResponse<StubPayloadType> = .init(
            data: nil,
            error: .init(
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
        )

        XCTAssertEqual(errorResponse.error, expectedResponseError.error)
    }
}
