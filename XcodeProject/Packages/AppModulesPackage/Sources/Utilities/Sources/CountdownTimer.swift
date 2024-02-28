//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation

public final class CountdownTimer {

    private let count: Int
    private var initialDate = Date()

    /// Run this on Main queue
    private var onUpdate: ((Int) -> Void)?

    /// Create countdown timer
    /// - Parameter interval: Countdown interval in seconds
    public init(interval: Int) {
        self.count = interval
    }

    public func run(_ onUpdate: ((Int) -> Void)?) {
        initialDate = Date()
        scheduleFireEvent()
        onUpdate?(count)
        self.onUpdate = onUpdate
    }

    /// Run with initial interval and initial onUpdate
    public func restart() {
        run(onUpdate)
    }

    private func fire() {
        let now = Date().timeIntervalSince(initialDate)
        let currentCount = count - Int(now)

        if currentCount > 0 {
            onUpdate?(currentCount)
            scheduleFireEvent()
        } else {
            onUpdate?(0)
        }
    }

    private func scheduleFireEvent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fire()
        }
    }
}
