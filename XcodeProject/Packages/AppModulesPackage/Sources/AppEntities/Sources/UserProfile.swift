//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public struct UserProfile: Hashable {

    public let id: String
    public let role: String
    public let phoneNumber: String
    public let firstName: String
    public let lastName: String
    public let displayName: String
    public let smallAvatar: Avatar?
    public let mediumAvatar: Avatar?
    public let originalAvatar: Avatar?

    public init(
        id: String,
        role: String,
        phoneNumber: String,
        firstName: String,
        lastName: String,
        displayName: String,
        smallAvatar: Avatar?,
        mediumAvatar: Avatar?,
        originalAvatar: Avatar?

    ) {
        self.id = id
        self.role = role
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.smallAvatar = smallAvatar
        self.mediumAvatar = mediumAvatar
        self.originalAvatar = originalAvatar
    }

    public static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum FriendRequestStatus: String {
    case approved
    case ingoing
    case outgoing
    case null

    public init(_ section: String) {
        switch section {
        case "approved": self = .approved
        case "ingoing": self = .ingoing
        case "outgoing": self = .outgoing
        case "null": self = .null
        default:
            assertionFailure("Section is undefined for index: \(section)")
            self = .null
        }
    }
}

public struct FoundUsersByPhoneNumber: Hashable {

    public let profile: UserProfile
    public var friendRequest: FriendRequestStatus
    public let originalNumber: String

    public init(
        profile: UserProfile,
        friendRequest: FriendRequestStatus,
        originalNumber: String
    ) {
        self.profile = profile
        self.friendRequest = friendRequest
        self.originalNumber = originalNumber
    }

    public static func == (lhs: FoundUsersByPhoneNumber, rhs: FoundUsersByPhoneNumber) -> Bool {
        return lhs.profile.id == rhs.profile.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(profile.id)
    }
}
