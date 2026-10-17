import Foundation

public struct PhoneNumberInput: Equatable {
    public let digits: String
    public let countryCode: String
    public let nationalLength: Int

    public init(_ text: String, countryCode: String, nationalLength: Int = 10) {
        self.digits = text.filter { "0123456789".contains($0) }
        self.countryCode = countryCode
        self.nationalLength = nationalLength
    }

    public var nationalDigits: String {
        if digits.count > nationalLength && digits.hasPrefix(countryCode) {
            return String(digits.dropFirst(countryCode.count))
        }
        return digits
    }

    public var isEmpty: Bool { digits.isEmpty }

    public var isValid: Bool {
        nationalDigits.count >= nationalLength
    }

    /// International digits used by the authentication API.
    public var requestValue: String {
        countryCode + digits
    }

    public var missingDigits: Int {
        max(0, nationalLength - nationalDigits.count)
    }
}

public struct SmsCodeInput: Equatable {
    public let digits: String
    public let requiredLength: Int

    public init(_ text: String, requiredLength: Int = 4) {
        self.digits = text.filter { "0123456789".contains($0) }
        self.requiredLength = requiredLength
    }

    public var isValid: Bool {
        digits.count == requiredLength
    }

    public var requestValue: String { digits }
}
