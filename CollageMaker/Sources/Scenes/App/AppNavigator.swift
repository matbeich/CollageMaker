//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import Photos
import SnapKit
import UIKit
import Utils

final class AppNavigator: NSObject {
    var rootViewController: CollageNavigationController

    init(context: AppContext = AppContext()) {
        self.context = context
        let controller = context.photoAuthService.isAuthorized ? TemplatePickerViewController(context: context) : PermissionsViewController()
        rootViewController = CollageNavigationController(rootViewController: controller)

        super.init()

        if let controller = controller as? TemplatePickerViewController {
            controller.delegate = self
        } else if let controller = controller as? PermissionsViewController {
            controller.delegate = self
        }
    }

    private func routeToTemplatePickerScene() {
        let templatePickerViewController = TemplatePickerViewController(context: context)
        templatePickerViewController.delegate = self

        rootViewController.pushViewController(templatePickerViewController, animated: true)
    }

    private func routeToCollageScene(with collage: Collage, templates: [CollageTemplate]) {
        let sceneController = CollageSceneViewController(collage: collage, templates: templates, context: context)
        sceneController.delegate = self

        rootViewController.pushViewController(sceneController, animated: true)
    }

    private func routeToPermissionScene() {
        let controller = PermissionsViewController()
        controller.delegate = self

        rootViewController.push(controller)
    }

    private func routeToShareScreen(with collage: Collage) {
        let shareController = ShareScreenViewController(collage: collage, context: context)
        shareController.delegate = self

        if UIDevice.current.userInterfaceIdiom == .pad {
            let point = rootViewController.rightItemPosition ?? .zero
            showInPopover(shareController, pinnedTo: point, withBlur: true)
        } else {
            rootViewController.pushViewController(shareController, animated: true)
        }
    }

    private func dismissToPrevious() {
        rootViewController.popViewController(animated: true)
    }

    private func addBlur(to view: UIView) {
        UIView.animate(withDuration: 0.3) {
            view.addSubview(self.blurView)
            self.blurView.alpha = 1.0
        }

        blurView.snp.remakeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    private func removeBlur() {
        UIView.animate(withDuration: 0.3,
                       animations: { self.blurView.alpha = 0 },
                       completion: { _ in
                           self.blurView.removeFromSuperview()
                           self.blurView.snp.removeConstraints()
        })
    }

    private func showInPopover(_ viewController: UIViewController, pinnedTo point: CGPoint, withBlur: Bool) {
        viewController.modalPresentationStyle = .popover
        viewController.preferredContentSize = CGSize(width: 400, height: 600)

        let popover = viewController.popoverPresentationController
        popover?.delegate = self
        popover?.sourceView = rootViewController.view
        popover?.sourceRect = CGRect(origin: point, size: .zero)
        popover?.permittedArrowDirections = .up

        if withBlur { addBlur(to: rootViewController.view) }
        rootViewController.present(viewController, animated: true, completion: nil)
    }

    private let context: AppContext
    private lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
}

extension AppNavigator: PermissionsViewControllerDelegate {
    func permissionViewControllerDidReceivePermission(_ controller: PermissionsViewController) {
        routeToTemplatePickerScene()
    }
}

extension AppNavigator: TemplatePickerViewControllerDelegate {
    func templatePickerViewController(_ controller: TemplatePickerViewController, templateController: TemplateBarCollectionViewController, didSelectTemplate template: CollageTemplate) {
        context.templateProvider.collage(from: template, size: .large) { [weak self] collage in
            guard let `self` = self, !(self.rootViewController.topViewController is CollageSceneViewController) else {
                return
            }

            self.routeToCollageScene(with: collage, templates: templateController.templates)
        }
    }
}

extension AppNavigator: CollageSceneViewControllerDelegate {
    func collageSceneViewController(_ controller: CollageSceneViewController, didEndEditingCollage collage: Collage) {
        routeToShareScreen(with: collage)
    }
}

extension AppNavigator: ShareScreenViewControllerDelegate {
    func shareScreenViewController(_ controller: ShareScreenViewController, didShareCollageImage image: UIImage?, withError error: SharingError?) {
        if error == .photoLibraryAccessDenied {
            routeToPermissionScene()
        }
    }

    func shareScreenViewControllerDidCancel(_ controller: ShareScreenViewController) {
        dismissToPrevious()
    }
}

extension AppNavigator: UIPopoverPresentationControllerDelegate {
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        guard let newPoint = rootViewController.rightItemPosition else {
            return
        }

        rect.initialize(to: CGRect(origin: newPoint, size: .zero))
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        removeBlur()
    }
}
