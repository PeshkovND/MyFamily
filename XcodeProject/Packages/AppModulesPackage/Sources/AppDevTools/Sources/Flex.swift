//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

struct FlexProvider {

    let flex = Flex {}
}

final class Flex {

    private let showingExplorer: () -> Void

    init(showingExplorer: @escaping () -> Void) {
        self.showingExplorer = showingExplorer
    }

    func showExplorer() {
        showingExplorer()
    }
}
