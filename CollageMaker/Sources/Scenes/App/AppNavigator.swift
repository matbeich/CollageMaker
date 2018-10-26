//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos
import UIKit
import Utils

final class AppNavigator {
    var rootViewController: UINavigationController

    init(context: AppContext = AppContext()) {
        self.context = context

        if context.photoAuthService.isAuthorized {
            let templatePickerController = TemplatePickerViewController(context: context)
            rootViewController = CollageNavigationController(rootViewController: templatePickerController)
            templatePickerController.delegate = self
        } else {
            let controller = PermissionsViewController()
            rootViewController = CollageNavigationController(rootViewController: controller)
            controller.delegate = self
        }
    }

    let context: AppContext
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
        let controller = ShareScreenViewController(collage: collage, context: context)

        controller.delegate = self
        rootViewController.pushViewController(controller, animated: true)
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
