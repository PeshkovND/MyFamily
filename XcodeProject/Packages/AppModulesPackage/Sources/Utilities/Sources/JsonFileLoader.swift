//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public final class JsonFileLoader {

    private static let logger: OSLogger = .init(
        config: .init(
            subsystemName: "jsonFileLoader",
            subsystemId: "app.utilityKit.jsonFileLoader",
            category: "DebugTools"
        )
    )

    public static func loadModel<T: Decodable>(
        from fileName: String,
        bundle: Bundle,
        decoder: JSONDecoder = .init()
    ) -> Result<T, Error> {

        guard let path = bundle.path(forResource: fileName, ofType: nil) else {
            return .failure(AnyLocalizedError(failureMessage: "Failed to locate file \(fileName)"))
        }

        guard let data = NSData(contentsOfFile: path) as Data? else {
            return .failure(AnyLocalizedError(failureMessage: "Failed to load \(T.self) from the file"))
        }

        do {
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            print(error)
            return .failure(error)
        }
    }

    public static func loadData(from fileName: String, bundle: Bundle) -> Data? {
        guard let path = bundle.path(forResource: fileName, ofType: nil) else {
            logger.debug(message: "Failed to locate file \(fileName)")
            return nil
        }
        guard let data = NSData(contentsOfFile: path) as Data? else {
            logger.debug(message: "Failed to locate file \(fileName)")
            return nil
        }
        return data
    }
}
