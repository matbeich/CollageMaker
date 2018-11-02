//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import UIKit
import Utils

final class AppNavigator: NSObject {
    let context: AppContext

    init(context: AppContext = AppContext()) {
        self.context = context
        super.init()
    }

    private func pinAsPopover(_ viewController: UIViewController, on point: CGPoint) {
        viewController.modalPresentationStyle = .popover

        let popover = viewController.popoverPresentationController
        popover?.delegate = self
        popover?.sourceView = rootViewController.view
        popover?.sourceRect = CGRect(origin: point, size: .zero)
        popover?.permittedArrowDirections = .up

        rootViewController.present(viewController, animated: true, completion: nil)
    }

    lazy var rootViewController: CollageNavigationController = {
        if context.photoAuthService.isAuthorized {
            let templatePickerController = TemplatePickerViewController(context: context)
            templatePickerController.delegate = self

            return CollageNavigationController(rootViewController: templatePickerController)
        } else {
            let controller = PermissionsViewController()
            controller.delegate = self

            return CollageNavigationController(rootViewController: controller)
        }
    }()
}

extension AppNavigator: PermissionsViewControllerDelegate {
    func permissionViewControllerDidReceivePermission(_ controller: PermissionsViewController) {
        let templatePickerViewController = TemplatePickerViewController(context: context)

        templatePickerViewController.delegate = self

        rootViewController.pushViewController(templatePickerViewController, animated: true)
    }
}

extension AppNavigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage) {
        let shareController = ShareScreenViewController(collage: collage, context: context)
        shareController.delegate = self

        if UIDevice.current.userInterfaceIdiom == .pad {
            pinAsPopover(shareController, on: CGPoint(x: 500, y: 100))
        } else {
            rootViewController.pushViewController(shareController, animated: true)
        }
    }
}

extension AppNavigator: ShareScreenViewControllerDelegate {
    func shareScreenViewController(_ controller: ShareScreenViewController, didShareCollageImage image: UIImage, withError error: SharingError?) {
        if error != nil {
            let controller = PermissionsViewController()
            controller.delegate = self

            rootViewController.push(controller)
        }
    }

    func shareScreenViewControllerDidCancel(_ controller: ShareScreenViewController) {
        rootViewController.popViewController(animated: true)
    }
}

extension AppNavigator: UIPopoverPresentationControllerDelegate {}

extension AppNavigator: TemplatePickerViewControllerDelegate {
    func templatePickerViewController(_ controller: TemplatePickerViewController, templateController: TemplateBarCollectionViewController, didSelectTemplate template: CollageTemplate) {
        context.templateProvider.collage(from: template, size: .large) { [weak self] collage in
            guard
                let `self` = self,
                !(self.rootViewController.topViewController is CollageSceneViewController)
            else {
                return
            }

            let sceneController = CollageSceneViewController(collage: collage, templates: templateController.templates, context: self.context)

            sceneController.delegate = self
            self.rootViewController.pushViewController(sceneController, animated: true)
        }
    }
}
