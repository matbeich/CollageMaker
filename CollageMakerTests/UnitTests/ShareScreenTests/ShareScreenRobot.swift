//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import UIKit

enum ShareScreenElements: RobotElement {
    case shareFooter
    case instagramButton
    case messagesButton
    case photosButton
    case otherButton

    var id: String {
        switch self {
        case .shareFooter: return Accessibility.View.shareFooter.id
        case .instagramButton: return Accessibility.Button.instagramButton.id
        case .messagesButton: return Accessibility.Button.messagesButton.id
        case .otherButton: return Accessibility.Button.otherButton.id
        case .photosButton: return Accessibility.Button.photosButton.id
        }
    }
}

class ShareScreenRobot: Robot {
    var window: UIWindow
    var context: AppContext
    var controller: ShareScreenViewController

    var shareService: ShareServiceType {
        return context.shareService
    }

    init(context: AppContext = .mock) {
        let collage: Collage = .testable

        self.context = context
        self.controller = ShareScreenViewController(collage: collage, context: context)
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = controller
        self.window.makeKeyAndVisible()
    }

    @discardableResult
    func shareTo(destination: ShareDestination) -> Self {
        switch destination {
        case .instagram:
            self.tap(ShareScreenElements.instagramButton)
        case .messages:
            self.tap(ShareScreenElements.messagesButton)
        case .photos:
            self.tap(ShareScreenElements.photosButton)
        case .other:
            self.tap(ShareScreenElements.otherButton)
        }

        let result = shareService.lastShareDestination == destination

        GREYAssertTrue(result, reason: "Reason: destination is \(result ? "correct" : "wrong")")

        return self
    }
}

extension Collage {
    static var testable: Collage {
        return Collage(cells: [CollageCell(image: UIImage.test, relativeFrame: .fullsized)])
    }
}
