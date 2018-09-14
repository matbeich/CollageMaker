//
//Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Foundation
import UIKit
import Utils

final class Navigator {
    init(authSerivce: PhotoAuthService = PhotoAuthService()) {
        self.authService = authSerivce
    }
    
    lazy var rootViewController: UINavigationController = {
        if authService.isAuthorized {
//            let controller = CollageSceneViewController()
//            controller.delegate = self
            
            
            let assets = PhotoLibraryService.getImagesAssets()
            let controller = ImagePickerCollectionViewController(assets: assets)
            
            
            let cellOne = CollageCell(color: .collagePink, image: nil, relativeFrame: RelativeFrame(x: 0, y: 0, width: 0.5, height: 1))
            let cellTwo = CollageCell(color: .gray, image: nil, relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 1))
            let someCell = CollageCell(color: .darkGray, image: nil, relativeFrame: RelativeFrame(x: 0.5, y: 0, width: 0.5, height: 0.5))
            let someAnotherCell = CollageCell(color: .lightGray, image: nil, relativeFrame: RelativeFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5))
            let oneMoreCollage = Collage(cells: [cellOne, cellTwo])
            let collage = Collage(cells: [cellOne, someCell, someAnotherCell])
            
            let templateBar = TemplateBarCollectionViewController(templates: [oneMoreCollage, collage, oneMoreCollage,collage, oneMoreCollage, collage])
            
            let new = CollageImagePickerViewController(main: controller, template: templateBar)
            
            return CollageNavigationController(rootViewController: new)
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
        
        rootViewController.pushViewController(controller, animated: true)
    }
}

extension Navigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, wantsToShare collage: Collage) {
        let previewImage = CollageRenderer.renderImage(from: collage, with: CGSize(width: 1500, height: 1500))
        let controller = ShareScreenViewController()
        
        controller.setCollagePreview(image: previewImage)
        controller.delegate = self
        
        rootViewController.pushViewController(controller, animated: true)
    }
}

extension Navigator: ShareScreenViewControllerDelegate {
    func shareScreenViewControllerShouldBeClosed(_ controller: ShareScreenViewController) {
        rootViewController.popViewController(animated: true)
    }
}
