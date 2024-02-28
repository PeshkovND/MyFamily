//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine

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

public protocol TableViewAdaptable: UITableViewDelegate {

    associatedtype Section: Hashable
    associatedtype Item: Hashable

    associatedtype ViewModel

    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Item>

    var dataSource: DataSource? { get set }

    func registerCells(in tableView: UITableView)
    func setDataSource(in tableView: UITableView)

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
