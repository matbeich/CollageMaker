//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import Photos
import UIKit
import Utils

final class Navigator {
    init(authSerivce: PhotoAuthService = PhotoAuthService()) {
        self.authService = authSerivce
    }

    lazy var rootViewController: UINavigationController = {
        if authService.isAuthorized {
            let assets = PhotoLibraryService.getImagesAssets()
            let controller = ImagePickerCollectionViewController(assets: assets)
            let imagePickSceneController = CollageTemplatePickViewController(imagePickerController: controller)

            imagePickSceneController.delegate = self

            return CollageNavigationController(rootViewController: imagePickSceneController)
        } else {
            let controller = PermissionsViewController()
            controller.delegate = self

            return CollageNavigationController(rootViewController: controller)
        }
    }()

    private let authService: PhotoAuthService
}

extension Navigator: PermissionsViewControllerDelegate {
    func permissionViewControllerDidReceivePermission(_ controller: PermissionsViewController) {
        let assets = PhotoLibraryService.getImagesAssets()
        let controller = ImagePickerCollectionViewController(assets: assets)
        let imagePickSceneController = CollageTemplatePickViewController(imagePickerController: controller)

        rootViewController.pushViewController(imagePickSceneController, animated: true)
    }
}

extension Navigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, share collage: Collage) {
        let previewImage = CollageRenderer.renderImage(from: collage, with: CGSize(width: 500, height: 500), borders: false)
        let controller = ShareScreenViewController()

        controller.setCollagePreview(image: previewImage)
        controller.delegate = self

        rootViewController.pushViewController(controller, animated: true)
    }
}

extension Navigator: ShareScreenViewControllerDelegate {
    func shareScreenViewControllerCancelSharing(_ controller: ShareScreenViewController) {
        rootViewController.popViewController(animated: true)
    }
}

extension Navigator: CollageTemplatePickViewControllerDelegate {
    func collageImagePickSceneViewController(_ controller: CollageTemplatePickViewController, templateController: TemplateBarCollectionViewController, didSelectTemplate: Collage) {
        let controller = CollageSceneViewController(collage: didSelectTemplate, templates: templateController.templates)
        controller.delegate = self

        rootViewController.pushViewController(controller, animated: true)
    }
}
