//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import CoreLocation

public extension CLLocationCoordinate2D {
    func distanceToInkilometres(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        return thisLocation.distance(from: otherLocation) / 1_000
    }
}
