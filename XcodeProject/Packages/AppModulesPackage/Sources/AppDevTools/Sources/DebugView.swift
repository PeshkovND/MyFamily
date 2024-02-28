//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit
import Combine
import Utilities
import AppDesignSystem
import AppEntities
import AppServices
import AppBaseFlow

import SnapKit

public final class DebugView: UIView {

    private static var logger = LoggerFactory.default

    public var onClose: () -> Void = {}

    private let env: Env
    private var designSystem = appDesignSystem
    private let debugStorage: DefaultsStorage
    private let authService: AuthService

    // Flex Explorer
    private let flexProvider: FlexProvider = .init()
    private var flex: Flex { flexProvider.flex }

    private var notificationCenter: NotificationCenter { .default }

    private var cancelableSet: Set<AnyCancellable> = .init()

    private var rootViewController: UIViewController? {
        window?.rootViewController
    }

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "In App Debugger"
        label.textColor = .black
        label.font = label.font.withSize(14)
        label.textAlignment = .center
        return label
    }()
    
    private var flexButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open FLEX Tool 🛠", for: .normal)
        return button
    }()
    
    private var buttonsContainer: UIView = .init()

    private var textFieldTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.setTitle("Show InputTextField Examples", for: .normal)
        return button
    }()
    
    private var colorPaletteButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.setTitle("Show Color Palette", for: .normal)
        return button
    }()
    
    private var featureFlagButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading
        button.setTitle("Show Feature Flags", for: .normal)
        return button
    }()

    private lazy var segments: UISegmentedControl = {
        let segments = UISegmentedControl(items: ["Dev", "Production"])
        switch env.apiBaseUrlString {
        case env.stagingApi:
            segments.selectedSegmentIndex = 0
        case env.productionApi:
            segments.selectedSegmentIndex = 1
        default:
            break
        }
        return segments
    }()
    
    private lazy var logoutButton: ActionButton = {
        let button = appDesignSystem.components.primaryActionButton
        button.setTitle("Logout", for: .normal)
        return button
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    // Example of subheadline
    private lazy var smsCodeSubheadlineTextView: UITextView = {
        let textView = NoSelectionTextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()

    private lazy var textViewInteractionHandler: TextViewCustomInteractionHandler = .init(
        actionName: GlobalConfig.EmbebbedTextAction.changePhone,
        actionHandler: {
            Self.logger.debug(message: "Custom action intercepted in TextView")
        }
    )

    // INFO:
    // Using `.shared` here since it's used for debugging purpose and
    // it's not provided with production code.
    // `shared` call extracted to class propery which makes it more explicit
    // It can be easily refactored if it's required later
    private var application: UIApplication { .shared } // swiftlint:disable:this explicit_singleton

    public init(
        authService: AuthService,
        debugStorage: DefaultsStorage,
        env: Env
    ) {
        self.authService = authService
        self.debugStorage = debugStorage
        self.env = env

        super.init(frame: .zero)

        setupViews()
    }

    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        
        addTitle()
        setupScrollView()
        addLogoutButton()
        addExampleForSubheadline()
    }

    @objc private func showFlexInfo() {
        guard let url = URL(string: "https://github.com/FLEXTool/FLEX/blob/master/README.md"),
              application.canOpenURL(url) else { return }
        application.open(url, options: [:])
    }

    @objc private func showFlexTool() {
        flex.showExplorer()
    }

    @objc private func show3rdPartyTestTextFields() {
        let vc = InputTextFieldExamplesViewController()
        window?.rootViewController?.present(vc, animated: true)
    }
    
    @objc private func showColorPalette() {
        let vc = ColorPaletteViewController()
        window?.rootViewController?.present(vc, animated: true)
    }

    @objc private func showFeatureFlags() {
        let vc = FeatureFlagsViewController(
            debugTogglesHolder: DebugTogglesHolder(
                debugStorage: debugStorage
            )
        )
        let nvc = UINavigationController(rootViewController: vc)
        window?.rootViewController?.present(nvc, animated: true)
        vc.onClose = { [weak self] in
            guard let self = self else { return }
            self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func addTitle() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.topMargin)
            $0.leading.equalTo(safeAreaLayoutGuide.snp.leadingMargin)
            $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailingMargin)
            $0.height.equalTo(44)
        }
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
        }
        
        setupStackView()
    }
    
    private func setupButtons() {
        flexButton.addTarget(self, action: #selector(showFlexTool), for: .touchUpInside)
        
        let flexInfoButton = UIButton(type: .infoLight)
        flexInfoButton.addTarget(
            self,
            action: #selector(showFlexInfo),
            for: .touchUpInside
        )
        
        buttonsContainer.addSubview(flexButton)
        buttonsContainer.addSubview(flexInfoButton)
        
        flexButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(buttonsContainer.snp.leading)
            $0.height.equalToSuperview()
        }
        
        flexInfoButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(buttonsContainer.snp.trailing)
            $0.height.equalToSuperview()
        }
        
        textFieldTextButton.addTarget(
            self,
            action: #selector(show3rdPartyTestTextFields),
            for: .touchUpInside
        )
        
        colorPaletteButton.addTarget(
            self,
            action: #selector(showColorPalette),
            for: .touchUpInside
        )
        
        featureFlagButton.addTarget(
            self,
            action: #selector(showFeatureFlags),
            for: .touchUpInside
        )
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        
        let stackViewItems = [
            segments,
            buttonsContainer,
            makeNetworkHistoryInfoButton(),
            textFieldTextButton,
            colorPaletteButton,
            featureFlagButton,
            smsCodeSubheadlineTextView
        ]
        
        stackViewItems.forEach(stackView.addArrangedSubview)
        
        setupButtons()
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().offset(20)
            $0.width.equalToSuperview().offset(-2 * 20)
        }
        
        segments.snp.makeConstraints {
            $0.height.equalTo(40)
        }

        buttonsContainer.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        textFieldTextButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        colorPaletteButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        stackView.setCustomSpacing(24, after: segments)
    }

    private func addExampleForSubheadline() {
        let subheadlineText = appDesignSystem.strings.signInWeSentCodeTo(
            formattedPhoneNumber: designSystem.formatter.formatPhoneNumber("1234567890")
        ).appending(". \(designSystem.strings.commonChange).")

        let attribuedText = subheadlineText.attributed(
            with: designSystem.styles.screenSubheadlineAttributes
        )
        .apply(
            link: .init(
                text: "\(designSystem.strings.commonChange).",
                url: GlobalConfig.EmbebbedTextAction.changePhoneUrl
            ),
            attributes: designSystem.styles.textViewLinkAttributes
        )

        smsCodeSubheadlineTextView.attributedText = attribuedText
        smsCodeSubheadlineTextView.delegate = textViewInteractionHandler
    }

    private func addLogoutButton() {
        addSubview(logoutButton)
        logoutButton.touchUpInsidePublisher
            .flatMap { [weak self] (_: Void) -> AnyPublisher<Result<Void, AppError>, Never> in
                Self.logger.debug(message: "Logout tapped")
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.authService.logout()
            }
            .sink { _ in }
            .store(in: &cancelableSet)
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.leading.equalTo(safeAreaLayoutGuide.snp.leading).inset(20)
            $0.trailing.equalTo(safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.height.equalTo(48)
        }
    }

    private func makeNetworkHistoryInfoButton() -> UIButton {
        let button = ActionButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.setTitle("How To View Network Logs? 🌐", for: .normal)
        button.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        button.touchUpInsidePublisher
            .sink { [weak self] in
                self?.showHowToViewNetworkLogsAlert()
            }
            .store(in: &cancelableSet)
        return button
    }

    private func showHowToViewNetworkLogsAlert() {
        let message = """
        Open FLEX Tool 🛠
        Choose Menu Item
        Open Network History
        * Enable network monitoring if needed
        """

        let openFlexAction: UIAlertAction = .init(
            title: "Open FLEX 🛠",
            style: .default
        ) { [weak self] _ in
            self?.showFlexTool()
        }

        rootViewController?.showAlert(
            title: "View Network Logs 🌐",
            message: message,
            actions: [openFlexAction, .closeAction()]
        )
    }
}

extension DebugView: DebuggerView {

    private var selectedApiUrlString: String {
        switch segments.selectedSegmentIndex {
        case 0: return env.stagingApi
        case 1: return env.productionApi
        case UISegmentedControl.noSegment: return env.apiBaseUrlString
        default:
            assertionFailure("Wrong segment index for env")
            return env.stagingApi
        }
    }

    private func notifyEnvChanges() {
        notificationCenter.post(
            name: .appDebugDidEnvChanged,
            object: self
        )
    }

    public func willClose() {
        guard env.apiBaseUrlString != selectedApiUrlString else { return }

        debugStorage.add(
            primitiveValue: selectedApiUrlString,
            forKey: GlobalConfig.Keys.currentApiBaseUrl
        )

        notifyEnvChanges()
    }

    public func willOpen() { }
}
