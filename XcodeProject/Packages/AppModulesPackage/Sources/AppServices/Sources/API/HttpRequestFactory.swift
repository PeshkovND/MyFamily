//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Alamofire

public struct HttpRequestFactory {

    public static var stub: HttpRequest<Params.None> {
        .init(endpoint: "", method: .get)
    }

    private let baseUrlProviding: () -> String

    public init(baseUrlProviding: @escaping () -> String) {
        self.baseUrlProviding = baseUrlProviding
    }

    private func endpoint(for path: String) -> String {
        let base = baseUrlProviding()
        return "\(base)\(path)"
    }
}

// MARK: - Requests

extension HttpRequestFactory {

    // MARK: - Auth Requests

    public func requestAuth(uuid: String, number: String) -> HttpRequest<Params.RequestAuth> {
        .init(
            endpoint: endpoint(for: "/auth/request"),
            method: .post,
            params: Params.RequestAuth.init(uuid: uuid, number: number),
            encoder: JSONParameterEncoder.default
        )
    }

    public func confirmAuth(
        uuid: String,
        number: String,
        code: String
    ) -> HttpRequest<Params.ConfirmAuth> {
        .init(
            endpoint: endpoint(for: "/auth/confirm"),
            method: .post,
            params: Params.ConfirmAuth(uuid: uuid, number: number, code: code),
            encoder: JSONParameterEncoder.default
        )
    }

    public func refreshToken(
        uuid: String,
        refreshToken: String
    ) -> HttpRequest<Params.RefreshToken> {
        .init(
            endpoint: endpoint(for: "/auth/refresh-token"),
            method: .post,
            params: Params.RefreshToken(uuid: uuid, refreshToken: refreshToken),
            encoder: JSONParameterEncoder.default
        )
    }

    public func logout() -> HttpRequest<Params.None> {
        .init(endpoint: endpoint(for: "/auth/logout"), method: .post)
    }

    // MARK: - User Profile Requests

    public func getUseProfile() -> HttpRequest<Params.None> {
        .init(endpoint: endpoint(for: "/profile"), method: .get)
    }

    public func uploadAvatar(data: Data) -> UploadImageHttpRequest {
        .init(
            endpoint: endpoint(for: "/profile/avatar"),
            multipartParam: .init(data: data, name: "avatar")
        )
    }
}

// MARK: - Request Params

public struct Params {

    // It's used as workaround to provide explicit type for request
    public struct None: Encodable {}

    public struct RequestAuth: Encodable {
        let uuid: String
        let number: String
        let access: String = "user"
    }

    public struct ConfirmAuth: Encodable {
        let uuid: String
        let number: String
        let access: String = "user"
        let code: String
    }

    public struct RefreshToken: Encodable {
        let uuid: String
        let refreshToken: String
    }
}
