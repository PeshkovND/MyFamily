//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

extension Optional where Wrapped == String {

    public var isNilOrEmpty: Bool {
        guard let self = self else {
            return true
        }
        return self.isEmpty
    }
}

extension String {

    public func matchesRegExp(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    public func removingRegexMatches(pattern: String, replaceWith: String = "") -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return nil }
    }
    /// Converts strings to data using `.utf8`
    /// - Returns: Data
    public func toData() -> Data {
        .init(self.utf8)
    }
}
