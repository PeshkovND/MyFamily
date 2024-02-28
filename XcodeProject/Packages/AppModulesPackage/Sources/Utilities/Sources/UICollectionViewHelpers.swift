//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public protocol CollectionViewAdaptable: UICollectionViewDelegate {

    associatedtype Section: Hashable
    associatedtype Item: Hashable

    associatedtype ViewModel

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Item>

    func registerCells(in collectionView: UICollectionView)
    func setDataSource(in collectionView: UICollectionView)

    init(viewModel: ViewModel)
}

public protocol CollectionViewLayoutProvider {
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout
}

extension NSDiffableDataSourceSnapshot {

    public func applyChanges(_ builder: (inout Self) -> Void) -> Self {
        var snapshot = self
        builder(&snapshot)
        return snapshot
    }
}
