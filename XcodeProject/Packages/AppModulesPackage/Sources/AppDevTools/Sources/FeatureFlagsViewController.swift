//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import AppDesignSystem
import UIKit
import AppServices

final class FeatureFlagsViewController: UITableViewController {

    private let designSystem = appDesignSystem

    private let cellReuseIdentifier: String = "\(FeatureFlagsCell.self)"
    
    private let debugTogglesHolder: DebugTogglesHolder
    
    private let featureFlagNames = DebugTogglesHolder.FeatureFlags.allCases
    private var featureFlagStates = [Int: Bool]()
    
    public var onClose: (() -> Void)?
    
    private var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.setTitle("Save", for: .normal)
        return button
    }()

    init(debugTogglesHolder: DebugTogglesHolder) {
        self.debugTogglesHolder = debugTogglesHolder

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        
        tableView.register(FeatureFlagsCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.topItem?.title = "Feature Flags"
        
        saveButton.addTarget(
            self,
            action: #selector(saveChanges),
            for: .touchUpInside)
        
        let rightBarSaveButton = UIBarButtonItem(customView: saveButton)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarSaveButton
    }
}

// MARK: - Table View Data Source

extension FeatureFlagsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? FeatureFlagsCell else {
            return UITableViewCell()
        }

        let featureFlag = featureFlagNames[indexPath.row]
        cell.featureFlagNameLabel.text = featureFlag.rawValue
        cell.featureFlagSwitch.isOn = debugTogglesHolder.toggleValue(for: featureFlag)
        
        featureFlagStates[indexPath.row] = cell.featureFlagSwitch.isOn
        cell.featureFlagSwitch.tag = indexPath.row
                        
        cell.featureFlagSwitch.addTarget(
            self,
            action: #selector(switchStateChanged(sender:)),
            for: .valueChanged)
                
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        featureFlagNames.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    @objc func switchStateChanged(sender: UISwitch) {
        featureFlagStates[sender.tag] = sender.isOn
    }
    
    @objc func saveChanges() {
        for i in 0..<featureFlagNames.count {
            debugTogglesHolder.putValue(value: featureFlagStates[i] ?? false, for: featureFlagNames[i])
        }
        
        onClose?()
    }
}

final class FeatureFlagsCell: UITableViewCell {
    
    private var designSystem = appDesignSystem
    
    lazy var featureFlagNameLabel: UILabel = {
        let label = UILabel()
        label.font = appDesignSystem.typography.body
        return label
    }()
    
    var featureFlagSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(featureFlagNameLabel)
        contentView.addSubview(featureFlagSwitch)
            
        contentView.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.trailing.leading.equalTo(safeAreaLayoutGuide)
        }
        
        featureFlagNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(contentView.snp.leading).offset(20)
        }
        
        featureFlagSwitch.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.trailing.equalTo(contentView.snp.trailing).inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }
}
