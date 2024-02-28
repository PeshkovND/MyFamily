//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AppEntities
import AppServices
import Combine
import UIKit
import AppBaseFlow

final class AccountRepository {

    typealias FetchProfileResult = Result<Account.Profile, AppError>
    typealias UploadAvatarResult = Result<Image, AppError>

    private let httpClient: AlamofireHttpClient
    private let requestFactory: HttpRequestFactory
    private let accountHolder: AccountHolder
    private let networkMapper: NetworkMapper

    init(
        httpClient: AlamofireHttpClient,
        requestFactory: HttpRequestFactory,
        accountHolder: AccountHolder,
        networkMapper: NetworkMapper
    ) {
        self.httpClient = httpClient
        self.requestFactory = requestFactory
        self.accountHolder = accountHolder
        self.networkMapper = networkMapper
    }

    func fetchProfile() -> AnyPublisher<FetchProfileResult, Never> {
        let publisher = httpClient.sendRequest(
            requestFactory.getUseProfile(),
            payloadType: UserProfilePayload.self
        )
        .flatMap { [weak self] (result: Result<UserProfilePayload, AppError>) -> Just<FetchProfileResult> in

            guard let self = self else {
                return Just<FetchProfileResult>(
                    .failure(.unexpected)
                )
            }

            return self.handleProfileResponse(result: result)
        }
        .eraseToAnyPublisher()

        return publisher
    }

    func uploadAvatarImage(
        _ image: UIImage,
        imageCompressionQuality: CGFloat = GlobalConfig.Network.imageCompressionQuality
    ) -> AnyPublisher<UploadAvatarResult, Never> {

        guard let data = image.jpegData(compressionQuality: imageCompressionQuality) else {
            // IMPROVE: Add more specific error
            return Just<UploadAvatarResult>(
                .failure(.unexpected)
            )
            .eraseToAnyPublisher()
        }

        let publisher = httpClient.sendUploadImageRequest(
            requestFactory.uploadAvatar(data: data),
            payloadType: ImagePayload.self
        )
        .flatMap { [weak self] (payloadResult: Result<ImagePayload, AppError>) -> Just<UploadAvatarResult> in
            guard let self = self else {
                return Just<UploadAvatarResult>(
                    .failure(.unexpected)
                )
            }
            return self.handleUploadAvatarRespose(result: payloadResult)
        }
        .eraseToAnyPublisher()
        return publisher
    }
}

// MARK: - Handling Response

private extension AccountRepository {

    func handleProfileResponse(
        result: Result<UserProfilePayload, AppError>
    ) -> Just<FetchProfileResult> {

        guard let account = accountHolder.account else {
            return Just<FetchProfileResult>(
                .failure(.unexpected)
            )
        }

        switch result {
        case .success(let payload):
            let profile = self.networkMapper.userProfile(from: payload, account: account)
            let updatedAccount = Account(
                alreadyRegistered: account.alreadyRegistered,
                profile: profile,
                settings: account.settings
            )

            self.accountHolder.updateAccount(updatedAccount)
            return Just<FetchProfileResult>(.success(profile))

        case .failure(let appError):
            return Just<FetchProfileResult>(.failure(appError))
        }
    }

    func handleUploadAvatarRespose(
        result: Result<ImagePayload, AppError>
    ) -> Just<UploadAvatarResult> {
        switch result {
        case .success(let payload):

            guard let account = accountHolder.account else {
                return Just<UploadAvatarResult>(
                    .failure(.unexpected)
                )
            }

            let image = networkMapper.image(from: payload)

            let profile: Account.Profile = .init(
                id: account.profile.id,
                createdAt: account.profile.createdAt,
                updatedAt: account.profile.updatedAt,
                firstName: account.profile.firstName,
                lastName: account.profile.lastName,
                displayName: account.profile.displayName,
                phoneNumber: account.profile.displayName,
                avatarImage: image
            )

            let updatedAccount = Account(
                alreadyRegistered: account.alreadyRegistered,
                profile: profile,
                settings: account.settings
            )

            accountHolder.updateAccount(updatedAccount)

            return Just<UploadAvatarResult>(.success(image))

        case .failure(let appError):
            return Just<UploadAvatarResult>(.failure(appError))
        }
    }
}

// MARK: - Network Payload

private struct UserProfilePayload: Payloadable {
    let id: String
    let firstName: String?
    let lastName: String?
    let displayName: String?
    let phoneNumber: String
    let avatar: ImagePayload?
}

private struct ImageInfoPayload: Payloadable {
    let width: Int?
    let height: Int?
    let url: String?
}

private struct ImagePayload: Payloadable {
    let small: ImageInfoPayload?
    let medium: ImageInfoPayload?
    let original: ImageInfoPayload?
}

// MARK: - Account

extension NetworkMapper {

    fileprivate func userProfile(
        from payload: UserProfilePayload,
        account: Account
    ) -> Account.Profile {

        let avatarImage: Image? = {
            guard let avatar = payload.avatar else { return nil }
            return image(from: avatar)
        }()

        let profile = Account.Profile(
            id: payload.id,
            createdAt: account.profile.createdAt,
            updatedAt: account.profile.updatedAt,
            firstName: payload.firstName ?? "",
            lastName: payload.lastName ?? "",
            displayName: payload.displayName ?? "",
            phoneNumber: payload.phoneNumber,
            avatarImage: avatarImage
        )
        return profile
    }

    fileprivate func image(from payload: ImagePayload) -> Image {
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
