//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import AVKit
import UIKit

protocol CameraAuthServiceType {
    var status: AVAuthorizationStatus { get }
    var isAuthorized: Bool { get }
    func reqestAuthorization(callback: @escaping (AVAuthorizationStatus) -> Void)
}

final class CameraAuthService: CameraAuthServiceType {
    var isAuthorized: Bool {
        if case .authorized = status {
            return true
        }

        return false
    }

    var status: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }

    func reqestAuthorization(callback: @escaping (AVAuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { callback(granted ? .authorized : .denied) }
        }
    }
}
