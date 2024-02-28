//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import XCTest
import Utilities
@testable import AppServices

final class ValidationErrorTests: XCTestCase {

    private var jsonDecoder: JSONDecoder = .init()

    private var detailedInfoJsonFile: String {
        "validation_error_detailed_info.json"
    }

    private var testBundle: Bundle {
        .module
    }

    override func setUp() {
        super.setUp()
        jsonDecoder = JSONDecoder()
    }

    func testThatValidationContextDecodedFromJson() throws {
        let json = """
        {
            "limit": 6,
            "value": 123,
            "label": "uuid",
            "key": "key"
        }
        """

        let data = json.toData()

        let context = try XCTUnwrap(
            try? jsonDecoder.decode(
                ValidationErrorPayload.Context.self,
                from: data
            )
        )

        XCTAssertEqual(context.limit, 6)
        XCTAssertEqual(context.value, 123)
        XCTAssertEqual(context.label, "uuid")
        XCTAssertEqual(context.key, "key")
    }

    func testThatValidationContextDecodedWithDefaultValuesFromJson() throws {
        let json = "{}"
        let data = json.toData()

        let context = try XCTUnwrap(
            try? jsonDecoder.decode(
                ValidationErrorPayload.Context.self,
                from: data
            )
        )

        XCTAssertEqual(context.limit, 0)
        XCTAssertEqual(context.value, 0)
        XCTAssertEqual(context.label, "")
        XCTAssertEqual(context.key, "")
    }

    func testThatValidationDetailedInfoDecodedFromJsonInlined() throws {
        let json = """
        {
            "message": "\\\"uuid\\\" length must be at least 6 characters long",
            "path": [
                "uuid"
            ],
            "type": "string.min",
            "context": {
                "limit": 6,
                "value": 123,
                "label": "uuid",
                "key": "key"
            }
        }
        """

        let data = json.toData()

        let detailedInfo = try XCTUnwrap(
            try? jsonDecoder.decode(
                ValidationErrorPayload.DetailedInfo.self,
                from: data
            )
        )

        XCTAssertEqual(detailedInfo.message, "\"uuid\" length must be at least 6 characters long")
        XCTAssertEqual(detailedInfo.path, ["uuid"])
        XCTAssertEqual(detailedInfo.type, "string.min")

        XCTAssertEqual(detailedInfo.context.limit, 6)
        XCTAssertEqual(detailedInfo.context.value, 123)
        XCTAssertEqual(detailedInfo.context.label, "uuid")
        XCTAssertEqual(detailedInfo.context.key, "key")
    }

    func testThatValidationDetailedInfoDecodedFromJsonFile() throws {
        let jsonData = try XCTUnwrap(
            JsonFileLoader.loadData(from: detailedInfoJsonFile, bundle: testBundle)
        )

        let detailedInfo = try XCTUnwrap(
            try? jsonDecoder.decode(
                ValidationErrorPayload.DetailedInfo.self,
                from: jsonData
            )
        )

        XCTAssertEqual(detailedInfo.message, "\"uuid\" length must be at least 6 characters long")
        XCTAssertEqual(detailedInfo.path, ["uuid"])
        XCTAssertEqual(detailedInfo.type, "string.min")

        let expectedContext: ValidationErrorPayload.Context = .init(
            limit: 6,
            value: 123,
            label: "uuid",
            key: "key"
        )

        XCTAssertEqual(detailedInfo.context, expectedContext)
    }

    func testThatValidationDetailedInfoDecodedWithDefaultValuesFromJson() throws {
        let json = "{}"

        let detailedInfo = try XCTUnwrap(
            try? jsonDecoder.decode(
                ValidationErrorPayload.DetailedInfo.self,
                from: json.toData()
            )
        )

        let expectedDetailedInfo: ValidationErrorPayload.DetailedInfo = .init(
            message: nil,
            path: nil,
            type: nil,
            context: nil
        )

        XCTAssertEqual(detailedInfo, expectedDetailedInfo)
        XCTAssertEqual(detailedInfo.message, "")
        XCTAssertEqual(detailedInfo.path, [])
        XCTAssertEqual(detailedInfo.type, "")
        XCTAssertEqual(detailedInfo.context, .stub)
    }
}
