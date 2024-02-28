//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct Formatter {

    init() {}
}

// MARK: - App Formatters

extension Formatter {
    /**
     Formats the given number string into a humean-reasable phone number string.

     - Parameter phoneNumber: The phone number to be formatted.
    */
    public func formatPhoneNumber(_ phoneNumber: String?) -> String {
        guard let phoneNumber = phoneNumber else { return "" }

        let firstPartSubstring = phoneNumber.prefix(3)
        let secondPartSubstring  = phoneNumber.dropFirst(3).prefix(3)
        let thirdParSubstring  = phoneNumber.dropFirst(6).prefix(4)

        let firstPart = String(firstPartSubstring)
        let secondPart = String(secondPartSubstring)
        let thirdPart = String(thirdParSubstring)

        if thirdPart.isEmpty && secondPart.isEmpty {
            return firstPart.count == 3 ? "(\(firstPart)) " : firstPart
        } else if thirdPart.isEmpty {
            return "(\(firstPart)) \(secondPart)"
        }

        return String(format: "(%@) %@-%@", firstPart, secondPart, thirdPart)
    }

    public func formatResentCodeString(interval: Int) -> String {
        let seconds = interval % 60
        let minutes = interval / 60

        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
}
