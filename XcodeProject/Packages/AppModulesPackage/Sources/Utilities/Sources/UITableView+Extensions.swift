//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

extension UITableView {

    /// Register a class for use in creating new table view cells.
    ///
    /// String representation of class is used as identifier
    /// - Parameter cellClass: cellClass to register
    public func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }

    /// Returns a reusable cell object of speficied type located by its identifier
    ///
    /// If custom cell has not been registered then assertion is occured and new created cell is returned as fallback
    /// - Parameter cellClass: Custom type of cell
    /// - Parameter indexPath: The index path specifying the location of the cell
    public func dequeue<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            assertionFailure("Cell is not registered")
            return T()
        }
        return cell
    }

    public func register<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        register(viewClass, forHeaderFooterViewReuseIdentifier: String(describing: viewClass))
    }

    public func dequeue<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: String(describing: viewClass)) as? T else {
            assertionFailure("view \(viewClass) is not registered")
            return T()
        }
        return view
    }
}
