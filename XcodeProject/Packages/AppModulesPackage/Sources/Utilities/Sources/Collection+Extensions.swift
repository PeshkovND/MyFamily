//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array {

    /// Failsafe equivalent to suffix(from:) method.
    /// Returns empty slice when out of bounds requested.
    public func safeSuffix(from start: Int) -> ArraySlice<Element> {
        guard self[safe: start] != nil else {
            return ArraySlice<Element>()
        }
        return suffix(from: start)
    }
}
