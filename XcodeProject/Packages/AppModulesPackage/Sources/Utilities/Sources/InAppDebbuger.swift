//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public protocol DebuggerView where Self: UIView {

    var onClose: () -> Void { get set }

    func willClose()
    func willOpen()
}

public final class InAppDebugger: NSObject {

    private let hostView: UIView = {
        let view = UIView()
        view.frame = UIScreen.main.bounds
        view.frame.origin.x = UIScreen.main.bounds.maxX
        return view
    }()

    private weak var window: UIWindow?
    private weak var contentView: DebuggerView?

    private var openingRecognizer: UIGestureRecognizer?
    private var closingRecognizer: UIGestureRecognizer?

    private var leftContentInset: CGFloat { 32 }

    public init(window: UIWindow?) {
        self.window = window

        window?.addSubview(hostView)
    }

    public func attach(debugView: DebuggerView) {
        contentView = debugView
        debugView.onClose = { [weak self] in self?.closeDebugView() }
        debugView.frame = .init(
            x: leftContentInset,
            y: hostView.bounds.origin.y,
            width: hostView.bounds.width - leftContentInset,
            height: hostView.bounds.height
        )

        hostView.addSubview(debugView)
        addSwipeRecognizers()
    }

    public func detachDebugView() {
        removeSwipeRecognizers()
        contentView?.removeFromSuperview()
    }

    private func addSwipeRecognizers() {
        guard let window = window, let contentView = contentView else { return }

        let openingRecognizer: UIGestureRecognizer = {
            let recognizer = UIScreenEdgePanGestureRecognizer(
                target: self,
                action: #selector(edgeSwipeToLeft(_:))
            )
            recognizer.edges = .right
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            return recognizer
        }()

        let closingRecognizer: UIGestureRecognizer = {
            let recognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(swipeAction(_:))
            )
            recognizer.direction = .right
            recognizer.cancelsTouchesInView = false
            return recognizer
        }()
        window.addGestureRecognizer(openingRecognizer)
        contentView.addGestureRecognizer(closingRecognizer)

        self.openingRecognizer = openingRecognizer
        self.closingRecognizer = closingRecognizer
    }

    private func removeSwipeRecognizers() {
        if let openingRecognizer = openingRecognizer {
            window?.removeGestureRecognizer(openingRecognizer)
        }
        if let closingRecognizer = closingRecognizer {
            contentView?.removeGestureRecognizer(closingRecognizer)
        }
    }

    @objc private func edgeSwipeToLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard sender.state == .recognized else { return }
        openDebuggerView()
    }

    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        guard case .right = sender.direction else { return }
        closeDebugView()
    }

    public func openDebuggerView() {
        contentView?.willOpen()
        UIView.animate(withDuration: 0.3) {
            self.hostView.frame.origin.x = 0
        }

        UIView.animate(withDuration: 0.1, delay: 0.2, options: []) {
            self.hostView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }

    private func closeDebugView() {
        contentView?.willClose()
        UIView.animate(withDuration: 0.3) {
            self.hostView.frame.origin.x = UIScreen.main.bounds.maxX
        }

        UIView.animate(withDuration: 0.1) {
            self.hostView.backgroundColor = .clear
        }
    }
}
extension InAppDebugger: UIGestureRecognizerDelegate {

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
