//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

/// Describes resources for loading within app like colors and images
protocol AppResource {
    init?(
        named name: String,
        in bundle: Bundle?,
        compatibleWith traitCollection: UITraitCollection?
    )
}

// MARK: - App Resources

extension UIColor: AppResource {}
extension UIImage: AppResource {}

// MARK: - SafeResource

/// Safe resource loading
protocol SafeResource {
    associatedtype Resource: AppResource

    /// Fallback resource
    var stub: Resource { get }

    /// Provide loaded resource by name or  `stub` if resource not found
    func valueOrStub(_ name: String) -> Resource
}

extension SafeResource {
    func valueOrStub(_ name: String) -> Resource {
        guard let resource = Resource.init(named: name, in: .module, compatibleWith: nil) else {
            assertionFailure(#"Resource named "\#(Resource.self).\#(name)" not found"#)
            return stub
        }
        return resource
    }
}
