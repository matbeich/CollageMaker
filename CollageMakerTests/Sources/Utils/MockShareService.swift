//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import Foundation
import Utils

final class MockShareService: ShareServiceType {
    var lastShareDestination: ShareDestination?

    func shareToMessages(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?) {
        lastShareDestination = .messages
        completion?(true, ActivityType.iMessage, nil)
    }

    func shareToOther(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?) {
        lastShareDestination = .other
        completion?(true, ActivityType.iMessage, nil)
    }

    func shareToInstagram(_ content: Shareable, in controller: UIViewController, with completion: ShareCompletion?) {
        lastShareDestination = .instagram
        completion?(true, ActivityType.instagram, nil)
    }

    func saveToPhotos(_ content: Shareable, in controller: UIViewController, with completion: SavePhotoCompletion?) {
        lastShareDestination = .photos
        completion?(true, PHAsset())
    }
}
