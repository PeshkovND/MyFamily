//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct Account: Codable {
    public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    
    public init(id: Int, photoURL: URL?, firstName: String, lastName: String) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
    }
}

// MARK: - Credentials

public struct Credentials: Codable {
    public let accessToken: String
    public let expirationDate: Date

    public init(accessToken: String, expirationDate: Date) {
        self.accessToken = accessToken
        self.expirationDate = expirationDate
    }
}
