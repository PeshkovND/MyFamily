//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public typealias StringAttributes = [NSAttributedString.Key: Any]

extension String {

    public func attributed(with attributes: StringAttributes) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
}

extension NSAttributedString {

    public struct Link {
        let text: String
        let url: URL

        public init(text: String, url: URL) {
            self.text = text
            self.url = url
        }
    }

    public func apply(links: [Link], attributes: StringAttributes = [:]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let text = self.string as NSString
        let linkRanges = links.map { text.range(of: $0.text) }

        guard linkRanges.allSatisfy({ $0.length > 0 }) else { return self }

        zip(links, linkRanges).forEach { link, range in
            attributedString.addAttributes(attributes, range: range)
            attributedString.addAttribute(.link, value: link.url, range: range)
        }

        return attributedString
    }

    public func apply(link: Link, attributes: StringAttributes = [:]) -> NSAttributedString {
        apply(links: [link], attributes: attributes)
    }
}
