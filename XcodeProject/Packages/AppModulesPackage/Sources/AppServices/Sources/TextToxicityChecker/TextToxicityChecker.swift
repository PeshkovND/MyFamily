//

import Foundation
import Combine

public class TextToxicityChecker {
    
    struct CheckToxicityParams: Encodable {
        let text: String
    }
    
    struct CheckToxicityPayload: Payloadable {
        let result: Bool
    }
    
    private let httpClient: AlamofireHttpClient
    private let endpoint = "http://127.0.0.1:5001/check_toxicity"
    private var setCancelable = Set<AnyCancellable>()
    
    public init(httpClient: AlamofireHttpClient) {
        self.httpClient = httpClient
    }
    
    public func checkToxicity(
        inputText: String,
        onSuccess: @escaping (Bool) -> Void,
        onFailure: @escaping () -> Void
    ) {
        httpClient.sendRequest(
            endpoint: endpoint,
            method: .post,
            params: CheckToxicityParams(text: inputText),
            encoder: .json,
            payloadType: CheckToxicityPayload.self
        )
        .sink(receiveValue: { result in
            switch result {
            case .success(let success):
                onSuccess(success.result)
            case .failure:
                onFailure()
            }
        })
        .store(in: &setCancelable)
    }
}
