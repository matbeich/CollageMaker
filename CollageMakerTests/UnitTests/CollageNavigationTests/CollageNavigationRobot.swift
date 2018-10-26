//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import Foundation

class CollageNavigationRobot: Robot {
    var window: UIWindow
    var context: AppContext
    var startController: CollageBaseViewController
    var controller: CollageNavigationController

    init(library: PhotoLibraryType = MockPhotoLibrary(assetsCount: 100)) {
        self.context = AppContext(photoLibrary: library)
        self.startController = TemplatePickerViewController(context: context)
        self.controller = CollageNavigationController(rootViewController: startController)

        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = controller
        self.window.makeKeyAndVisible()
    }

    @discardableResult
    func navigateToCollageScene() -> Robot {
        self.expect(ImagePickerElements.imageCollectionView, isVisible: true)
            .tap(ImagePickerElements.image_cell(0))
            .expect(TemplatePickerElements.templateView, isVisible: true)
            .tap(NavigationControllerElements.select)
            .expect(CollageSceneElements.collageView, isVisible: true)

        return self
    }
}
