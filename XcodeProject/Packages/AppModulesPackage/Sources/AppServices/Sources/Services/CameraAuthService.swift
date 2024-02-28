//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import Foundation
import AVFoundation

public final class CameraAuthService {

    public var accessGranted: () -> Void = {}
    public var accessDenied: () -> Void = {}

    public init() {}

    public func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            accessGranted()
        case .notDetermined:
            requestAccessToCamera()
        case .denied, .restricted:
            accessDenied()
        @unknown default:
            assertionFailure("Handle new auth statuses")
            accessDenied()
        }
    }

    private func requestAccessToCamera() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            self.handleAuthResult(granted: granted)
        }
    }

    private func handleAuthResult(granted: Bool) {
        DispatchQueue.main.async {
            if granted {
                self.accessGranted()
            } else {
                self.accessDenied()
            }
        }
    }
}
