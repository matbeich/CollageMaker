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
    var context: AppContext

    var cellsCount: Int {
        return controller.collageViewController.collageView.cellViews.count
    }

    init(context: AppContext = .mock) {
        self.context = context

        let collage: Collage = .testable
        let templates = context.templateProvider.templates(for: [PHAsset()])

        self.controller = CollageSceneViewController(collage: collage, templates: templates, context: context)
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = CollageNavigationController(rootViewController: controller)
        self.window.makeKeyAndVisible()
    }

    @discardableResult
    func splitBy(axis: Axis) -> Self {
        let cellsCount = self.cellsCount

        return self.tap(axis == .horizontal ? CollageSceneElements.horizontalButton : CollageSceneElements.verticalButton)
            .expect(CollageSceneElements.collageView, cellsCountEqualsTo: cellsCount + 1)
    }

    @discardableResult
    func deleteCell() -> Self {
        let cellsCount = self.cellsCount

        return self.tap(CollageSceneElements.deleteButton)
            .expect(CollageSceneElements.collageView, cellsCountEqualsTo: cellsCount - 1)
    }

    @discardableResult
    func addImage() -> Self {
        return self.tap(CollageSceneElements.addImageButton)
            .expect(ImagePickerElements.imageCollectionView, isVisible: true)
            .tap(ImagePickerElements.image_cell(0))
            .expect(CollageSceneElements.collageView, isVisible: true)
    }

    @discardableResult
    func expect(_ element: RobotElement, cellsCountEqualsTo: Int) -> Self {
        let assertion = GREYAssertions.cellsCountEquals(to: cellsCountEqualsTo)
        element.greyInteraction.assert(assertion)

        return self
    }
}

fileprivate extension GREYAssertions {
    static func cellsCountEquals(to: Int) -> GREYAssertion {
        return GREYAssertionBlock(name: "") { (element: Any?, errorOrNil: UnsafeMutablePointer<NSError?>?) -> Bool in
            guard let view = element as? CollageView else {
                return false
            }

            return view.cellViews.count == to
        }
    }
}
