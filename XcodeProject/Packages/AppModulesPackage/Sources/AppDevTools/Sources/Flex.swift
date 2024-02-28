//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

// TODO: Implement Flex library if it's needed

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
