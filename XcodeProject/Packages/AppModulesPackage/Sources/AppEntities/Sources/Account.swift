//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct Account: Codable {
    public let id: Int
    public let photoURL: URL?
    public let firstName: String
    public let lastName: String
    public let familyId: String?
    public let role: Role
    
    public init(id: Int, photoURL: URL?, firstName: String, lastName: String, familyId: String?, role: Role) {
        self.id = id
        self.photoURL = photoURL
        self.firstName = firstName
        self.lastName = lastName
        self.familyId = familyId
        self.role = role
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
