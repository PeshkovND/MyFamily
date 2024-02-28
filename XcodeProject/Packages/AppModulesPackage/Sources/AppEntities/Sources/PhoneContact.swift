//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct PhoneContact: Codable {

    public var personId: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String
    public var thumbnailImageData: Data?

    public init(
        personId: String,
        firstName: String,
        lastName: String,
        phoneNumber: String,
        thumbnailImageData: Data?
    ) {
        self.personId = personId
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.thumbnailImageData = thumbnailImageData
    }

    public static var stub: PhoneContact {
        .init(
            personId: "1",
            firstName: "John",
            lastName: "Doe",
            phoneNumber: "8887775555",
            thumbnailImageData: nil
        )
    }
}
