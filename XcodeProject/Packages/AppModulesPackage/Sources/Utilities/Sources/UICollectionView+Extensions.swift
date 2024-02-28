//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: UICollectionView

extension UICollectionView {

    /// Register a class for use in creating new collection view cells.
    ///
    /// String representation of class is used as identifier
    /// - Parameter cellClass: CellClass to register
    public func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }

    /// Returns a reusable cell object of speficied type located by its identifier
    ///
    /// If custom cell has not been registered then assertion is occured and new created cell is returned as fallback
    /// - Parameter cellClass: Custom type of cell
    /// - Parameter indexPath: The index path specifying the location of the cell
    public func dequeue<T: UICollectionViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            assertionFailure("Cell is not registered")
            return T()
        }
        return cell
    }

    /// Register a class for use in creating new collection view supplementary views - headers.
    ///
    /// String representation of class is used as identifier
    /// - Parameter viewClass: UICollectionReusableView class to register
    public func registerHeader<T: UICollectionReusableView>(_ viewClass: T.Type) {
        registerSupplementary(viewClass, kind: UICollectionView.elementKindSectionHeader)
    }

    /// Register a class for use in creating new collection view supplementary views - footers.
    ///
    /// String representation of class is used as identifier
    /// - Parameter viewClass: UICollectionReusableView class to register
    public func registerFooter<T: UICollectionReusableView>(_ viewClass: T.Type) {
        registerSupplementary(viewClass, kind: UICollectionView.elementKindSectionFooter)
    }

    /// Returns a reusable header view of speficied type located by its kind
    ///
    /// If custom view has not been registered then assertion is occured and new created view is returned as fallback
    /// - Parameter viewClass: Custom type of reusable view
    /// - Parameter indexPath: The index path specifying the location of the cell
    public func dequeHeader<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueSupplementary(viewClass, kind: UICollectionView.elementKindSectionHeader, for: indexPath)
    }

    /// Returns a reusable footer view of speficied type located by its kind
    ///
    /// If custom view has not been registered then assertion is occured and new created view is returned as fallback
    /// - Parameter viewClass: Custom type of reusable view
    /// - Parameter indexPath: The index path specifying the location of the cell
    public func dequeFooter<T: UICollectionReusableView>(_ viewClass: T.Type, for indexPath: IndexPath) -> T {
        return dequeueSupplementary(viewClass, kind: UICollectionView.elementKindSectionFooter, for: indexPath)
    }

    /// Register a class for use in creating new collection view supplementary views.
    ///
    /// String representation of class is used as identifier
    /// - Parameter viewClass: UICollectionReusableView class to register
    /// - Parameter kind: one of UICollectionView.elementKindSectionHeader or *Footer
    private func registerSupplementary<T: UICollectionReusableView>(_ viewClass: T.Type, kind: String) {
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: viewClass))
    }

    /// Returns a reusable view of speficied type located by its kind
    ///
    /// If custom view has not been registered then assertion is occured and new created view is returned as fallback
    /// - Parameter viewClass: Custom type of reusable view
    /// - Parameter kind: Either UICollectionView.elementKindSectionHeader or *Footer
    /// - Parameter indexPath: The index path specifying the location of the cell
    private func dequeueSupplementary<T: UICollectionReusableView>(_ viewClass: T.Type, kind: String, for indexPath: IndexPath) -> T {
        let id = String(describing: viewClass)
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? T else {
            assertionFailure("Supplementary view is not registered")
            return T()
        }
        return view
    }
}
