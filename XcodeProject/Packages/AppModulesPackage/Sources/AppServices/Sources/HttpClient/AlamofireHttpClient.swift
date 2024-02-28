//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Combine

import Utilities
import Alamofire
import AppEntities

// MARK: - AlamofireHttpClient

public final class AlamofireHttpClient {

    private let session: Session
    private let errorMapper: ResponseErrorMapper = .init()

    public init(
        urlSessionConfiguration: URLSessionConfiguration,
        requestInterceptor: RequestInterceptor,
        eventMonitors: [EventMonitor]
    ) {
        self.session = Session(
            configuration: urlSessionConfiguration,
            interceptor: requestInterceptor,
            eventMonitors: eventMonitors
        )
    }

    public func sendRequest<Params: Encodable, Payload: Payloadable>(
        endpoint: String,
        method: HTTPMethod,
        params: Params?,
        encoder: ParameterEncoder,
        payloadType: Payload.Type
    ) -> AnyPublisher<Result<Payload, AppError>, Never> {

        session.request(
            endpoint,
            method: method,
            parameters: params,
            encoder: encoder,
            headers: nil,
            interceptor: nil,
            requestModifier: nil
        )
        .processResponse(errorMapper: errorMapper)
    }

    public func sendUploadImageRequest<Payload: Payloadable>(
        _ request: UploadImageHttpRequest,
        payloadType: Payload.Type
    ) -> AnyPublisher<Result<Payload, AppError>, Never> {

        session.upload(
            multipartFormData: { miltipartFormData in
                miltipartFormData.append(
                    request.multipartParam.data,
                    withName: request.multipartParam.name,
                    fileName: request.multipartParam.fileName,
                    mimeType: request.multipartParam.mimeType
                )
            },
            to: request.endpoint
        )
        .processResponse(errorMapper: errorMapper)
    }
}

// MARK: - AlamofireHttpClient + HttpRequest

extension AlamofireHttpClient {

    public func sendRequest<Params: Encodable, Payload: Payloadable>(
        _ request: HttpRequest<Params>,
        payloadType: Payload.Type
    ) -> AnyPublisher<Result<Payload, AppError>, Never> {
        sendRequest(
            endpoint: request.endpoint,
            method: request.method,
            params: request.params,
            encoder: request.encoder,
            payloadType: Payload.self
        )
    }
}

extension DataRequest {

    func processResponse<Payload: Payloadable>(
        errorMapper: ResponseErrorMapper
    ) -> AnyPublisher<Result<Payload, AppError>, Never> {
        self
            .validate(statusCode: 200..<500)
            .publishDecodable(
                type: HttpResponse<Payload>.self,
                queue: DispatchQueue.global(qos: .utility)
            )
            .value()
            .mapError { (afError: AFError) -> AppError in
                let error = errorMapper.makeAppError(from: afError)
                return error
            }
            .tryMap { (httpResponse: HttpResponse<Payload>) -> Payload in
                if let error = httpResponse.error {
                    throw errorMapper.makeAppError(from: error)
                }

                if let payload = httpResponse.data {
                    return payload
                }

                throw AppError.undefined(
                    causedError: AnyLocalizedError(failureMessage: "Response is empty")
                )
            }
            .mapError {
                guard let appError = $0 as? AppError else {
                    return AppError.network(causedByError: AnyLocalizedError.unexpected)
                }
                return appError
            }
            .map { (payload: Payload) -> Result<Payload, AppError> in
                .success(payload)
            }
            .catch { (error: AppError) -> Just<Result<Payload, AppError>> in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}
