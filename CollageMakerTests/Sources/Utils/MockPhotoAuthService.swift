//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Foundation

final class MockPhotoAuthService: PhotoAuthServiceType {
    var status: PhotoAuthService.Status = .authorized
    var isAuthorized: Bool { return true }
}
