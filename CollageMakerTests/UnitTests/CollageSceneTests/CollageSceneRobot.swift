//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import Foundation

class CollageSceneRobot: Robot {
    var window: UIWindow
    var controller: CollageSceneViewController

    init() {
        self.controller = CollageSceneViewController(templates: [])
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = controller
        self.window.makeKeyAndVisible()
    }
}

enum CollageSceneElements: RobotElement {
    case collageView

    var id: String {
        switch self {
        case .collageView: return Accessibility.View.collageView.id
        default: return ""
        }
    }
}
