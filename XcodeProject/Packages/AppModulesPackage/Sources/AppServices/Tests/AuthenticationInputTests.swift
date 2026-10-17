import XCTest
import AppEntities

final class AuthenticationInputTests: XCTestCase {

    func testFormattedNationalPhoneNumber() {
        let input = PhoneNumberInput("(234) 567-8900", countryCode: "1")
        XCTAssertTrue(input.isValid)
        XCTAssertEqual(input.nationalDigits, "2345678900")
        XCTAssertEqual(input.requestValue, "12345678900")
        XCTAssertEqual(input.missingDigits, 0)
    }

    func testShortPhoneNumber() {
        let input = PhoneNumberInput("234", countryCode: "1")
        XCTAssertFalse(input.isValid)
        XCTAssertEqual(input.missingDigits, 7)
    }

    func testEmptyPhoneNumber() {
        let input = PhoneNumberInput("", countryCode: "1")
        XCTAssertTrue(input.isEmpty)
        XCTAssertFalse(input.isValid)
    }

    func testSmsCodeRemovesFormatting() {
        let input = SmsCodeInput("12 34")
        XCTAssertTrue(input.isValid)
        XCTAssertEqual(input.requestValue, "1234")
        XCTAssertFalse(SmsCodeInput("12").isValid)
    }

    func testCompleteProfile() {
        let profile = ProfileCompletion(
            firstName: "Alex",
            lastName: "Smith",
            displayName: "Alex S."
        )
        XCTAssertTrue(profile.isComplete)
        XCTAssertTrue(profile.missingFields.isEmpty)
        XCTAssertEqual(profile.completedFieldCount, 3)
    }

    func testWhitespaceProfile() {
        let profile = ProfileCompletion(firstName: " ", lastName: "\n", displayName: "")
        XCTAssertFalse(profile.isComplete)
        XCTAssertEqual(profile.missingFields.count, 3)
    }

    func testCredentialsWithFutureExpiration() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let credentials = Credentials(
            accessToken: "access",
            refreshToken: "refresh",
            expirationDate: now.addingTimeInterval(120)
        )
        XCTAssertTrue(credentials.isUsable(at: now))
        XCTAssertFalse(credentials.needsRefresh(at: now))
    }

    func testExpiredCredentialsNeedRefresh() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let credentials = Credentials(
            accessToken: "access",
            refreshToken: "refresh",
            expirationDate: now.addingTimeInterval(-120)
        )
        XCTAssertFalse(credentials.isUsable(at: now))
        XCTAssertTrue(credentials.needsRefresh(at: now))
    }
}
