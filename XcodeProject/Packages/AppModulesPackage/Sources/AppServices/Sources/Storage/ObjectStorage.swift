//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public protocol ObjectStorage {

    func object<T: Codable>(forKey key: String) -> T?

    func add<T: Codable>(object: T, forKey key: String)

    func removeObject(forKey key: String)

    func clearAll()
}

// MARK: - MemoryStorage

public final class MemoryStorage: ObjectStorage {

    private var dict = [String: Any]()

    public init() {}

    public func object<T>(forKey key: String) -> T? {
        return dict[key] as? T
    }

    public func add<T>(object: T, forKey key: String) {
        dict[key] = object
    }

    public func removeObject(forKey key: String) {
        dict.removeValue(forKey: key)
    }

    public func clearAll() {
        dict.removeAll()
    }
}

// MARK: - DefaultsStorage

public final class DefaultsStorage: ObjectStorage {

    public static var fallbackStorage: DefaultsStorage { .init() }

    static var logger: Logger { LoggerFactory.makeStub() }

    private let userDefaults: UserDefaults
    private let suiteName: String
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        self.suiteName = "undefined"
        self.userDefaults = UserDefaults.standard
        self.encoder = .init()
        self.decoder = .init()
    }

    public init?(
        suiteName: String,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            return nil
        }
        self.suiteName = suiteName
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }

    public func object<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            Self.logger.debug(
                message: "Decoding value for key: \(key) with error: \(error)"
            )
        }
        return nil
    }

    public func add<T: Codable>(object: T, forKey key: String) {
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            Self.logger.debug(
                message: "Encoding value: \(object) for key: \(key) with error: \(error)"
            )
        }
    }

    public func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    public func clearAll() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}

public extension DefaultsStorage {

    func add<T>(primitiveValue: T, forKey key: String) {
        userDefaults.set(primitiveValue, forKey: key)
    }

    func primitiveValue<T>(forKey key: String) -> T? {
        guard let storedValue = userDefaults.value(forKey: key) else {
            Self.logger.debug(
                message: "Value for key \(key) not found in storage \(Self.self)"
            )
            return nil
        }

        guard let typedValue = storedValue as? T else {
            Self.logger.debug(
                message: "Value \(storedValue) for key \(key) can not be cast to \(T.self)"
            )
            return nil
        }

        return typedValue
    }
}
