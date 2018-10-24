//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos
import UIKit
import Utils

final class AppNavigator {
    var rootViewController: UINavigationController

    init(authSerivce: PhotoAuthService = PhotoAuthService(),
         templateProvider: CollageTemplateProvider = CollageTemplateProvider()) {
        self.authService = authSerivce
        self.templateProvider = templateProvider

        if authService.isAuthorized {
            let templatePickerController = TemplatePickerViewController()
            rootViewController = CollageNavigationController(rootViewController: templatePickerController)
            templatePickerController.delegate = self
        } else {
            let controller = PermissionsViewController()
            rootViewController = CollageNavigationController(rootViewController: controller)
            controller.delegate = self
        }
    }

    private let authService: PhotoAuthService
    private let templateProvider: CollageTemplateProvider
}

extension AppNavigator: PermissionsViewControllerDelegate {
    func permissionViewControllerDidReceivePermission(_ controller: PermissionsViewController) {
        let templatePickerViewController = TemplatePickerViewController()
        templatePickerViewController.delegate = self

        rootViewController.pushViewController(templatePickerViewController, animated: true)
    }
}

extension AppNavigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage) {
        let controller = ShareScreenViewController(collage: collage)

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
        templateProvider.collage(from: template, size: .large) { [weak self] collage in
            let sceneController = CollageSceneViewController(collage: collage, templates: templateController.templates)
            sceneController.delegate = self

            guard !(self?.rootViewController.topViewController is CollageSceneViewController) else {
                return
            }

            self?.rootViewController.pushViewController(sceneController, animated: true)
        }
    }
}
