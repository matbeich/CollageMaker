//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Utils

final class CollageNavigationController: UINavigationController {
    var navBarHeight: CGFloat = CollageNavigationController.preferredNavBarHeight {
        didSet {
            changeSafeAreaInset(top: navBarHeight)
            layout()
        }
    }

    var rootViewController: UIViewController? {
        guard viewControllers.count > 0 else {
            return nil
        }

        return viewControllers[0]
    }

    var navBarItem: NavigationBarItem? {
        didSet {
            updateNavBar()
        }
    }

    var showBackButton: Bool = true {
        didSet {
            updateNavBar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        navigationBar.isHidden = true
        navBar.passInsideTouches = false
        view.addSubview(navBar)

        layout()
        changeSafeAreaInset(top: navBarHeight)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        layout()
    }

    @objc private func back() {
        pop(animated: true, completion: nil)
    }

    private func layout() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height

        navBar.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(navBarHeight)
        }
    }

    private func updateNavBar() {
        let showBack = topViewController != rootViewController && showBackButton
        let leftItem = navBarItem?.left ?? (showBack ? backButton : nil)

        navBar.leftItem = leftItem
        navBar.rightItem = navBarItem?.right
        navBar.titleItem = navBarItem?.titleItem
    }

    private func changeSafeAreaInset(top: CGFloat) {
        additionalSafeAreaInsets.top = top
    }

    private lazy var navBar = NavigationBar()
    private lazy var backButton = NavigationBarButtonItem(icon: R.image.back_btn(), target: self, action: #selector(back))
}

extension CollageNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? CollageBaseViewController {
            navBarItem = controller.navBarItem
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let controller = viewController as? CollageBaseViewController, let savedItem = navBarItem else {
            return
        }

        navBarItem = controller.navBarItem
        let snaphot = navBar.asImage()
        navBarItem = savedItem

        let snaphotView = UIImageView(frame: navBar.frame)

        snaphotView.image = snaphot
        snaphotView.alpha = 0

        view.addSubview(snaphotView)

        let animation: (UIViewControllerTransitionCoordinatorContext) -> Void = { _ in
            snaphotView.alpha = 1.0
            self.navBar.alpha = 0.0
        }

        viewController.transitionCoordinator?.animateAlongsideTransition(in: navBar, animation: animation) { [weak self] ctx in
            if ctx.isCancelled {
                self?.navBarItem = savedItem
            }

            self?.navBar.alpha = 1.0
            snaphotView.removeFromSuperview()
        }
    }
}

extension CollageNavigationController {
    static var preferredNavBarHeight: CGFloat {
        return 59
    }
}

final class NavigationBarItem {
    var back: NavigationItem?
    var left: NavigationItem?
    var right: NavigationItem?
    var titleItem: NavigationItem?

    var title: String? {
        didSet {
            updateTitleItem(with: title)
        }
    }

    init(title: String?) {
        self.title = title
        updateTitleItem(with: title)
    }

    private func updateTitleItem(with title: String?) {
        self.titleItem = title != nil ? NavigationBarLabelItem(title: title, color: .black, font: R.font.sfProDisplaySemibold(size: 19)) : nil
    }
}

extension UIViewController {
    var collageNavigationController: CollageNavigationController? {
        return navigationController as? CollageNavigationController
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
