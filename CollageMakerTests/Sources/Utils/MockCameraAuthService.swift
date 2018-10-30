//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import AVKit
@testable import CollageMaker
import Foundation

final class MockCameraAuthService: CameraAuthServiceType {
    var status: AVAuthorizationStatus {
        return AVAuthorizationStatus.authorized
    }

    var isAuthorized: Bool = true
    func reqestAuthorization(callback: @escaping (AVAuthorizationStatus) -> Void) { callback(status) }
}
