//  

import Foundation

public extension URL {
    public func stringWithoutScheme() -> String? {
        let urlString = self.absoluteString
        if let url = URL(string: urlString) {
            let pathWithoutScheme = urlString.replacingOccurrences(of: "\(url.scheme ?? "")://", with: "")
            return pathWithoutScheme
        } else {
            return nil
        }
    }
}
