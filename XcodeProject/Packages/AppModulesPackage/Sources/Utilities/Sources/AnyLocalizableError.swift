//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct AnyLocalizedError: LocalizedError {

    private let message: String

    public var errorDescription: String? { message }

    public init(failureMessage: String) {
        self.message = failureMessage
    }

    public static var unexpected: AnyLocalizedError { .init(failureMessage: "Unexpected error occured") }
}
