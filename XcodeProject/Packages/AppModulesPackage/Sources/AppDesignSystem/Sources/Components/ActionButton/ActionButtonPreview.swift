//  Copyright © 2021 Krasavchik OOO. All rights reserved.

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG

import UIKit
import SwiftUI

struct ViewControllerRepresentable: UIViewRepresentable {

    let providingUIView: () -> UIView

    init(providingUIView: @escaping () -> UIView) {
        self.providingUIView = providingUIView
    }

    func makeUIView(context: Context) -> UIView {
        providingUIView()
    }

    func updateUIView(_ view: UIView, context: Context) {}
}

struct PrimaryActionButtonPreview: PreviewProvider {

    static var previews: some View {
        Group {
            ViewControllerRepresentable {
                appDesignSystem.components.primaryActionButton
            }
            .frame(width: 360.0, height: 50.0)
            .colorScheme(.light)
            .previewDisplayName("Primary ActionButton")
        }
    }
}

#endif
