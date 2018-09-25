//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit
import Utils

class CollageNavigationController: UINavigationController {
    var navBarHeight: CGFloat = .navBarHeight {
        didSet {
            changeSafeAreaInset(top: navBarHeight)
            layout()
        }
    }

    var navBarItem: NavigationBarItem = NavigationBarItem(left: nil, right: nil, title: nil) {
        didSet {
            setupNavBar(leftItem: navBarItem.left, rightItem: navBarItem.right, titleItem: navBarItem.title)
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

    private func layout() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height

        navBar.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(navBarHeight)
        }
    }

    private func setupNavBar(leftItem: NavigationItem? = nil, rightItem: NavigationItem? = nil, titleItem: NavigationItem? = nil) {
        navBar.leftItem = leftItem
        navBar.rightItem = rightItem
        navBar.titleItem = titleItem
    }

    private func changeSafeAreaInset(top: CGFloat) {
        additionalSafeAreaInsets.top = top
    }

    private var navBar = NavigationBar()
}

extension CollageNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? CollageBaseViewController {
            navBarItem = controller.navBarItem
        }
    }
}

class NavigationBarItem {
    let left: NavigationItem?
    let right: NavigationItem?
    let title: NavigationItem?

    init(left: NavigationItem? = nil, right: NavigationItem? = nil, title: NavigationItem? = nil) {
        self.left = left
        self.right = right
        self.title = title
    }
}

extension UIViewController {
    var collageNavigationController: CollageNavigationController? {
        guard let collageNavigationController = navigationController as? CollageNavigationController else {
            return nil
        }

        return collageNavigationController
    }
}
