//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities

// MARK: - NetworkMapper

public final class NetworkMapper {

    private static var logger: Logger { LoggerFactory.default }

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withFractionalSeconds
        ]

        return formatter
    }()

    public init() {}

    public func convertToDate(_ string: String) -> Date {
        guard let date = dateFormatter.date(from: string) else {
            Self.logger.error(
                message: "\(string) cannot be converted to Date type!"
            )
            return Date()
        }
        return date
    }
}

// MARK: - Auth

extension NetworkMapper {

    func accountWithCreds(
        from payload: AuthorizedUserPayload
    ) -> (account: Account, credentials: Credentials) {

        let avatarImage: Image? = {
            guard let avatar = payload.profile.avatar else { return nil }
            return image(from: avatar)
        }()

        let profile = Account.Profile(
            id: payload.profile.id,
            createdAt: convertToDate(payload.profile.createdAt),
            updatedAt: convertToDate(payload.profile.updatedAt),
            firstName: payload.profile.firstName ?? "",
            lastName: payload.profile.lastName ?? "",
            displayName: payload.profile.displayName ?? "",
            phoneNumber: payload.profile.phoneNumber,
            avatarImage: avatarImage
        )

        let settings: Account.Settings = .init(
            mute: payload.settings.mute
        )

        let credentials = Credentials(
            accessToken: payload.token.accessToken,
            expirationDate: convertToDate(payload.token.expiresIn)
        )

        return (
            account: .init(
                alreadyRegistered: payload.alreadyRegistered,
                profile: profile,
                settings: settings
            ),
            credentials: credentials
        )
    }

    private func image(from payload: ImagePayload) -> Image {
        let infoList: [Image.Info?] = [payload.small, payload.medium, payload.original]
            .map { (infoPaload: ImageInfoPayload?) -> Image.Info? in
                guard let info = infoPaload,
                      let width = info.width,
                      let height = info.height,
                      let url = info.url else {
                    return nil
                }
                return Image.Info(width: width, height: height, url: url)
            }
        return Image(
            small: infoList[0],
            medium: infoList[1],
            original: infoList[2]
        )
    }
}
