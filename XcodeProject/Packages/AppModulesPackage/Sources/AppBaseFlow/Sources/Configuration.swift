//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public struct GlobalConfig {

    public struct Keys {
        public static var currentApiBaseUrl: String { "currentApiBaseUrl" }
        public static var onboardingCompleted: String { "key_onboarding_completed" }
    }

    public struct PhoneNumber {
        public static var validFormattedPhoneLength: Int { 14 }
        public static var validInputPhoneLength: Int { 10 }
        public static var validDigits: String { "0123456789" }
        public static var countryCode: String { "1" }
    }

    public struct AppURL {
        public static var termsOfService: URL { URL(string: "https://google.com") ?? appSiteUrl }
        public static var privacyPolicy: URL { URL(string: "https://google.com") ?? appSiteUrl }
    }

    @available(*, deprecated, message: "Use url config instead!. It will be removed nex updates")
    public struct Links {
        public static var termsOfService: String { "https://google.com" }
        public static var privacyPolicy: String { "https://google.com" }
    }

    public struct SmsCode {
        public static var validInputSmsLength: Int { 4 }
        public static var validDigits: String { "0123456789" }
        public static var timeIntervalForResentCode: Int { 60 }
    }

    public struct EmbebbedTextAction {
        public static var changePhone: String { "action_change_phone" }
        public static var changePhoneUrl: URL { URL(string: changePhone) ?? appSiteUrl }
    }

    public struct FirstName {
        public static var maxСharacters: Int { 12 }
        public static var minСharacters: Int { 3 }
        public static var inputFieldValidationPattern: String { "^[a-zA-z]*$" }
    }

    public struct LastName {
        public static var maxСharacters: Int { 12 }
        public static var minСharacters: Int { 3 }
        public static var inputFieldValidationPattern: String { "^[A-Za-z0-9_-]*$" }
    }

    public struct DisplayName {
        public static var maxСharacters: Int { 30 }
        public static var minСharacters: Int { 6 }
        public static var inputFieldValidationPattern: String { "^[A-Za-z0-9_-]*$" }
    }

    public struct Network {
        public static var refreshWindowTimeInterval: TimeInterval { 60 * 5 }
        public static var imageCompressionQuality: CGFloat { 0.9 }
    }

    public struct ErrorsApiCode {
        public static var invalidSMSCode: String { "1202" }
        public static var expiredSMSCode: String { "1201" }
        public static var exceedLimitSMSCode: String { "1101" }
    }

    // It's used as fallback url and for avoiding unwrapping urls
    private static var appSiteUrl: URL {
        URL(string: "https://google.com")!  // swiftlint:disable:this force_unwrapping
    }
    
    private init() {}
}

// MARK: - Debug

extension Notification.Name {

    public static var appDebugDidEnvChanged: Self { .init("appDebugDidEnvChanged") }
}
