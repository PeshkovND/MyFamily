//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public typealias Avatar = Image.Info

public struct Image: Hashable, Codable {

    public let small: Info?
    public let medium: Info?
    public let original: Info?

    public init(small: Info?, medium: Info?, original: Info?) {
        self.small = small
        self.medium = medium
        self.original = original
    }
}

extension Image {

    public struct Info: Hashable, Codable {

        public let width: Int
        public let height: Int
        public let url: String

        public init(
            width: Int,
            height: Int,
            url: String
        ) {
            self.width = width
            self.height = height
            self.url = url
        }
    }
}
