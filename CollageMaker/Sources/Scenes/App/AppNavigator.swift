//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos
import UIKit
import Utils

final class AppNavigator {
    init(authSerivce: PhotoAuthService = PhotoAuthService()) {
        self.authService = authSerivce
        self.templateProvider = CollageTemplateProvider()
    }

    lazy var rootViewController: UINavigationController = {
        if authService.isAuthorized {
            let templatePickerController = TemplatePickerViewController()

            templatePickerController.delegate = self

            return CollageNavigationController(rootViewController: templatePickerController)
        } else {
            let controller = PermissionsViewController()
            controller.delegate = self

            return CollageNavigationController(rootViewController: controller)
        }
    }()

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
