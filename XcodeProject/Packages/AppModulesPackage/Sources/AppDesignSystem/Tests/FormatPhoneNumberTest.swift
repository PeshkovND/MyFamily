//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import XCTest
import AppDesignSystem

final class FormatPhoneNumberTest: XCTestCase {

    private let designSystem = appDesignSystem

    func testNilPhoneNumberString() {
        let sourcePhoneString: String? = nil
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = ""

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }

    func testEmptyPhoneNumberString() {
        let sourcePhoneString: String = ""
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = ""

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }

    func testOnlyNotFullFirstPartPhoneNumberString() {
        let sourcePhoneString: String? = "22"
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = "22"

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }

    func testOnlyfirstPartPhoneNumberString() {
        let sourcePhoneString: String? = "222"
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = "(222) "

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }

    func testFirstAndSecondPartsPhoneNumberString() {
        let sourcePhoneString: String? = "22222"
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = "(222) 22"

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }

    func testFullPhoneNumberString() {
        let sourcePhoneString: String? = "222555888"
        let formatingPhoneString = appDesignSystem.formatter.formatPhoneNumber(sourcePhoneString)
        let expectedPhoneString: String = "(222) 555-888"

        XCTAssertEqual(formatingPhoneString, expectedPhoneString)
    }
}
