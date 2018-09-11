//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import AVKit

final class CameraAuthService {
    
    var isAuthorized: Bool {
        if case .authorized = status {
            return true
        }
        
        return false
    }
    
    var status: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func reqestAuthorization(callback: @escaping (AVAuthorizationStatus) -> Void ) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { callback(granted ? .authorized : .denied) }
        }
    }
}
