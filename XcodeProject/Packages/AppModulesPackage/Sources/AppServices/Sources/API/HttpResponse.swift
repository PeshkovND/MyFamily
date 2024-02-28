//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public protocol Payloadable: Decodable {}

struct HttpResponse<Payload: Payloadable>: Payloadable {
    let data: Payload?
    let error: ClientErrorPayload?
}

struct ClientErrorPayload: Error, Payloadable, Equatable {

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
        case validationError = "fieldErrors"
    }

    let code: String?
    let message: String?
    let validationError: ValidationErrorPayload?
}

// MARK: - DetailedInfo

struct ValidationErrorPayload: Payloadable, Equatable {
    let body: [DetailedInfo]?
    let params: [DetailedInfo]?
    let query: [DetailedInfo]?
}

extension ValidationErrorPayload {

    // MARK: - DetailedInfo

    struct DetailedInfo: Payloadable, Equatable {

        enum CodingKeys: String, CodingKey {
            case _message = "message"
            case _path = "path"
            case _type = "type"
            case _context = "context"
        }

        var message: String { _message ?? "" }
        var path: [String] { _path ?? [] }
        var type: String { _type ?? "" }
        var context: Context { _context ?? .stub }

        private let _message: String?
        private let _path: [String]?
        private let _type: String?
        private let _context: Context?

        init(
            message: String?,
            path: [String]?,
            type: String?,
            context: Context?
        ) {
            self._message = message
            self._path = path
            self._type = type
            self._context = context
        }
    }

    // MARK: - Context

    struct Context: Payloadable, Equatable {

        enum CodingKeys: String, CodingKey {
            case _limit = "limit"
            case _value = "value"
            case _label = "label"
            case _key = "key"
        }

        var limit: Int { _limit ?? 0 }
        var value: Int { _value ?? 0 }
        var label: String { _label ?? "" }
        var key: String { _key ?? "" }

        private let _limit: Int?
        private let _value: Int?
        private let _label: String?
        private let _key: String?

        static var stub: Context { .init(limit: nil, value: nil, label: nil, key: nil) }

        init(
            limit: Int?,
            value: Int?,
            label: String?,
            key: String?
        ) {
            self._limit = limit
            self._value = value
            self._label = label
            self._key = key
        }
    }
}
