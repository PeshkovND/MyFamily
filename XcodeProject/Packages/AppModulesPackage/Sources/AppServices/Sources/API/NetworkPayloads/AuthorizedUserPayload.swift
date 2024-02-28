//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

// MARK: - ConfirmAuth

struct AuthorizedUserPayload: Payloadable {

    let alreadyRegistered: Bool
    let profile: ProfilePayload
    let settings: SettingsPayload
    let token: TokenPayload
}

// MARK: - Profile

struct ProfilePayload: Payloadable {

    let id: String
    let createdAt: String
    let updatedAt: String
    let firstName: String?
    let lastName: String?
    let displayName: String?
    let phoneNumber: String
    let avatar: ImagePayload?
}

struct ImageInfoPayload: Payloadable {
    let width: Int?
    let height: Int?
    let url: String?
}

struct ImagePayload: Payloadable {
    let small: ImageInfoPayload?
    let medium: ImageInfoPayload?
    let original: ImageInfoPayload?
}

// MARK: - Settings

struct SettingsPayload: Payloadable {
    let mute: Bool
}

// MARK: - Token

struct TokenPayload: Payloadable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: String
}
