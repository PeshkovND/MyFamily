//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import AppDesignSystem
import UIKit
import AppBaseFlow

final class ColorPaletteViewController: UIViewController {

    private let designSystem = appDesignSystem

    private lazy var colorPalette = appDesignSystem.colors.colorSections

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Color palette"
        label.font = appDesignSystem.typography.headline
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        collectionView.backgroundColor = appDesignSystem.colors.backgroundPrimary

        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        addTitle()
        
        addCollectionView()
    }

    private func addTitle() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)

        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        collectionView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: 0
        ).isActive = true

        collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true

        collectionView.register(ColorPaletteCollectionViewCell.self)
        collectionView.register(
            ColorPaletteSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(ColorPaletteSectionHeaderView.self)")

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

final class ColorPaletteCollectionViewCell: BaseCollectionViewCell {

    var contentCellView: ColorPaletteItemView { typedGenericView() }

    override func makeCellView() -> ColorPaletteItemView { .init() }

    override func provideCustomLayout() -> (() -> Void)? {
        { [weak self] in
            guard let self = self else { return }
            self.contentCellView.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
}

final class ColorPaletteItemView: BaseView {

    private var designSystem = appDesignSystem

    private(set) lazy var circleView: UIView = {
        let view = UIView()
        view.layer.borderColor = appDesignSystem.colors.backgroundSecondary.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 15
        return view
    }()

    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = appDesignSystem.colors.backgroundSecondary
        label.font = label.font.withSize(14)
        return label
    }()
    
    private(set) lazy var hexAndRgbaLabel: UILabel = {
        let label = UILabel()
        label.textColor = appDesignSystem.colors.labelSecondary
        label.font = label.font.withSize(14)
        return label
    }()

    override func setLayout() {
        addSubview(circleView)
        addSubview(nameLabel)
        addSubview(hexAndRgbaLabel)

        circleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 30, height: 30))
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(circleView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        hexAndRgbaLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(circleView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}

extension ColorPaletteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPalette[section].count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { colorPalette.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ColorPaletteCollectionViewCell.self, indexPath: indexPath)
        let section = colorPalette[indexPath.section]
        let item = section[indexPath.row]
        let contentView = cell.contentCellView
        contentView.circleView.backgroundColor = item.color
        contentView.nameLabel.text = item.name
        contentView.hexAndRgbaLabel.text = item.hexAndRgba
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = CGSize()
        size.height = 24
        size.width = 30
        
        return size
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "\(ColorPaletteSectionHeaderView.self)",
                    for: indexPath) as? ColorPaletteSectionHeaderView
            else {
                fatalError("Invalid view type")
            }
            
            let sectionHeader: String
            
            switch indexPath.section {
            case 0:
                sectionHeader = "Label"
            case 1:
                sectionHeader = "Background"
            case 2:
                sectionHeader = "Fill"
            default:
                sectionHeader = "Invalid section"
            }

            headerView.titleLabel.text = sectionHeader
            
            return headerView
        default:
            fatalError("Invalid view type")
        }
    }
}

extension ColorPaletteViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: UIScreen.main.bounds.width,
            height: 50
        )
    }
}

final class ColorPaletteSectionHeaderView: UICollectionReusableView {
    
    private var designSystem = appDesignSystem

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = appDesignSystem.typography.headline
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().inset(32)
        }
    }
}
