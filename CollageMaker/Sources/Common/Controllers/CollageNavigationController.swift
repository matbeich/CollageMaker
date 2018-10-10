//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Utils

class CollageNavigationController: UINavigationController {
    var navBarHeight: CGFloat = CollageNavigationController.preferredNavBarHeight {
        didSet {
            changeSafeAreaInset(top: navBarHeight)
            layout()
        }
    }
    
    var navBarItem: NavigationBarItem? {
        didSet {
            setupNavBar(leftItem: navBarItem?.left, rightItem: navBarItem?.right, titleItem: navBarItem?.title)
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
    
    private lazy var navBar = NavigationBar()
}

extension CollageNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? CollageBaseViewController {
            navBarItem = controller.navBarItem
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let controller = viewController as? CollageBaseViewController, let current = navBarItem else {
            return
        }
        
        navBarItem = controller.navBarItem
        let snaphot = navBar.asImage()
        navBarItem = current
        
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
                self?.navBarItem = current
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

struct NavigationBarItem {
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
