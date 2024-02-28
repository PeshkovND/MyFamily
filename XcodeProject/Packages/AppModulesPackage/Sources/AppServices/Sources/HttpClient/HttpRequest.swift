//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import Alamofire

public struct HttpRequest<Params: Encodable> {
    let endpoint: String
    let method: HTTPMethod
    let params: Params?
    let encoder: ParameterEncoder

    public init(endpoint: String, method: HTTPMethod) {
        self.endpoint = endpoint
        self.method = method
        self.params = nil
        self.encoder = URLEncodedFormParameterEncoder.default
    }

    public init(endpoint: String, method: HTTPMethod, params: Params, encoder: ParameterEncoder) {
        self.endpoint = endpoint
        self.method = method
        self.params = params
        self.encoder = encoder
    }
}

public struct UploadImageHttpRequest {

    public struct MultipartParam {
        let data: Data
        let name: String
        let fileName: String = "image.jpg"
        let mimeType: String = "image/jpeg"

        public init(data: Data, name: String) {
            self.data = data
            self.name = name
        }
    }

    let endpoint: String
    let multipartParam: MultipartParam

    public init(endpoint: String, multipartParam: MultipartParam) {
        self.endpoint = endpoint
        self.multipartParam = multipartParam
    }
}
