//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

@testable import CollageMaker
import EarlGrey
import Foundation

enum ImagePickerElements: RobotElement {
    case image_cell(Int)
    case imageCollectionView

    var id: String {
        switch self {
        case let .image_cell(index): return Accessibility.View.imagePickerCell(id: index).id
        case .imageCollectionView: return Accessibility.View.imageCollectionView.id
        }
    }
}

enum TemplatePickerElements: RobotElement {
    case templateView
    case template_cell(Int)

    var id: String {
        switch self {
        case let .template_cell(index): return Accessibility.View.templateCell(id: index).id
        case .templateView: return Accessibility.View.templateView.id
        }
    }
}

class TemplatePickerRobot: Robot {
    var window: UIWindow
    var context: AppContext
    var controller: TemplatePickerViewController

    init(library: PhotoLibraryType = MockPhotoLibrary(assetsCount: 100)) {
        self.context = AppContext(photoLibrary: library)
        self.controller = TemplatePickerViewController(context: context)
        self.window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 375.0, height: 667.0)))
        self.window.rootViewController = CollageNavigationController(rootViewController: controller)
        self.window.makeKeyAndVisible()
    }

    @discardableResult
    func selectImage(at index: UInt) -> TemplatePickerRobot {
        if selected.contains(index) { return self }

        selected.insert(index)
        image(at: index).perform(grey_tap())
        return self
    }

    @discardableResult
    func deselectAllImages() -> TemplatePickerRobot {
        selected.forEach(deselectImage(at:))

        return self
    }

    func deselectImage(at index: UInt) {
        image(at: index).perform(grey_tap())
    }

    @discardableResult
    func selectAnyImage() -> TemplatePickerRobot {
        let randomIndex = UInt(arc4random_uniform(UInt32(controller.selectedCellsCount)))
        selectImage(at: randomIndex)

        return self
    }

    @discardableResult
    func selectTemplate(at index: UInt) -> CollageSceneRobot {
        template(at: index).perform(grey_tap())

        return CollageSceneRobot()
    }

    @discardableResult
    func expect(_ element: RobotElement, isVisible: Bool) -> TemplatePickerRobot {
        if element.id == Accessibility.View.templateView.id {
            let assertion = GREYAssertions.isFullyOnScreen(isVisible)
            element.greyInteraction.assert(assertion)
        } else {
            let matcher = isVisible ? grey_sufficientlyVisible() : grey_notVisible()
            element.greyInteraction.assert(matcher)
        }

        return self
    }

    private func image(at index: UInt) -> GREYInteraction {
        let id = Int(index)
        let imageCell = EarlGrey.selectElement(with: grey_accessibilityID(Accessibility.View.imagePickerCell(id: id).id)).using(searchAction: grey_scrollInDirectionWithStartPoint(.down, 400, 0.75, 0.75), onElementWithMatcher: grey_accessibilityID(Accessibility.View.imageCollectionView.id))

        return imageCell
    }

    private func template(at index: UInt) -> GREYInteraction {
        let id = Int(index)
        let templateCell = EarlGrey.selectElement(with: grey_accessibilityID(Accessibility.View.templateCell(id: id).id)).using(searchAction: grey_scrollInDirection(.right, 600), onElementWithMatcher: grey_accessibilityID(Accessibility.View.templateCollectionView.id))

        return templateCell
    }

    private var selected = Set<UInt>()
}

public extension GREYAssertions {
    static func isFullyOnScreen(_ flag: Bool) -> GREYAssertion {
        return GREYAssertionBlock(name: "Is Fully On Screen") { (element: Any?, errorOrNil: UnsafeMutablePointer<NSError?>?) -> Bool in
            guard let view = element as? UIView, let superview = view.superview else {
                return false
            }

            let result = superview.bounds.contains(view.frame) && !view.frame.isEmpty

            return flag ? result : !result
        }
    }
}
