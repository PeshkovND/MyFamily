//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public protocol FormattedJSON {
    var prettyPrintedString: String? { get }
}

extension Data: FormattedJSON {

    public var prettyPrintedString: String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) else { return nil }

        return prettyPrintedString
    }
}

extension Dictionary: FormattedJSON {

    public var prettyPrintedString: String? {
        guard let prettyPrintedData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]),
            let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) else { return nil }

        return prettyPrintedString
    }
}
