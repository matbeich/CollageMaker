//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import Foundation
import Photos

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
    var library: PhotoLibraryType
    var templateProvider: CollageTemplateProvider

    init(library: PhotoLibraryType = MockPhotoLibrary()) {
        let collage = Collage(cells: [CollageCell(color: .white, image: UIImage.test, photoAsset: nil, relativeFrame: .fullsized)])

        self.templateProvider = CollageTemplateProvider(photoLibrary: MockPhotoLibrary())
        let templates = templateProvider.templates(for: Array(1 ... 3).map { _ in PHAsset() })
        self.controller = CollageSceneViewController(collage: collage, templates: templates, templateProvider: templateProvider)
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = CollageNavigationController(rootViewController: controller)
        self.window.makeKeyAndVisible()
    }

    @discardableResult
    func splitHorizontaly() -> Self {
        return self.tap(CollageSceneElements.horizontalButton)
    }

    @discardableResult
    func splitVerticaly() -> Self {
        return self.tap(CollageSceneElements.verticalButton)
    }

    @discardableResult
    func deleteCell() -> Self {
        return self.tap(CollageSceneElements.deleteButton)
    }

    @discardableResult
    func addImage() -> Self {
        return self.tap(CollageSceneElements.addImageButton)
            .expect(ImagePickerElements.imageCollectionView, isVisible: true)
            .tap(ImagePickerElements.image_cell(0))
            .expect(CollageSceneElements.collageView, isVisible: true)
    }
}
