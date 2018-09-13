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
            let controller = CollageSceneViewController()
            controller.delegate = self
            
            return CollageNavigationController(rootViewController: controller)
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
        let controller = CollageSceneViewController()
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
