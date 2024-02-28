//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: - BaseTableViewCell

open class BaseTableViewCell: UITableViewCell {

    private(set) lazy var genericCellView: UIView = makeCellView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.addSubview(genericCellView)
        selectionStyle = .none

        setCellViewLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func makeCellView() -> UIView {
        assertionFailure("It's not intended to use")
        return UIView()
    }

    public func setCellViewLayout() {
        genericCellView.translatesAutoresizingMaskIntoConstraints = false

        genericCellView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor
        ).isActive = true

        genericCellView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor
        ).isActive = true

        genericCellView.topAnchor.constraint(
            equalTo: contentView.topAnchor
        ).isActive = true

        genericCellView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor
        ).isActive = true
    }

    public func typedGenericView<T: UIView>() -> T {
        guard let view = genericCellView as? T else {
            assertionFailure("Generic cell view cannot be casted to type \(T.self)")
            return T()
        }
        return view
    }
}

// MARK: - Example for custom cell

//final class CustomTableViewCell: BaseTableViewCell {
//
//    var myContentView: MyContentView { typedGenericView() }
//
//    override func makeCellView() -> MyContentView { .init() }
//}
