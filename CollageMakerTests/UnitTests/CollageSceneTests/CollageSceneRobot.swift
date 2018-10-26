//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import Foundation


enum CollageSceneElements: RobotElement {
    case deleteButton
    case horizontalButton
    case verticalButton
    case addImageButton
    case collageView
    
    var id: String {
        switch self {
        case .horizontalButton: return Accessibility.Button.horizontalButton.id
        case .verticalButton: return Accessibility.Button.verticalButton.id
        case .addImageButton: return Accessibility.Button.addImageButton.id
        case .deleteButton: return Accessibility.Button.deleteButton.id
        case .collageView: return Accessibility.View.collageView.id
        }
    }
}

class CollageSceneRobot: Robot {
    var window: UIWindow
    var controller: CollageSceneViewController

    init() {
        let collage = Collage(cells: [CollageCell(color: .white, image: UIImage.test, photoAsset: nil, relativeFrame: .fullsized)])

        self.controller = CollageSceneViewController(collage: collage)
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = CollageNavigationController(rootViewController: controller)
        self.window.makeKeyAndVisible()
    }
    
    func splitHorizontaly() {
        self.tap(CollageSceneElements.horizontalButton)
    }
}
