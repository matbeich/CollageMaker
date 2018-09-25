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
            let templatePickerController = TemplatePickerViewController(assets: assets)

            templatePickerController.delegate = self

            return CollageNavigationController(rootViewController: templatePickerController)
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
        let imagePickSceneController = TemplatePickerViewController(assets: assets)

        rootViewController.pushViewController(imagePickSceneController, animated: true)
    }
}

extension Navigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage) {
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

extension Navigator: TemplatePickerViewControllerDelegate {
    func templatePickerViewController(_ controller: TemplatePickerViewController, templateController: TemplateBarCollectionViewController, didSelect: CollageTemplate) {
        CollageTemplateProvider.collage(from: didSelect, size: .large) { [weak self] collage in
            let controller = CollageSceneViewController(collage: collage, templates: templateController.templates)
            controller.delegate = self

            self?.rootViewController.pushViewController(controller, animated: true)
        }
    }
}
