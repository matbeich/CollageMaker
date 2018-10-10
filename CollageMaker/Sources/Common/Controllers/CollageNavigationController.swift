//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import UIKit
import Utils

protocol CollageNavigationControllerDelegate: AnyObject {
    func collageNavigationControllerdidTappedLeftButton(_ controller: CollageNavigationController)
}

final class CollageNavigationController: UINavigationController {
    weak var buttonsDelegate: CollageNavigationControllerDelegate?

    struct Preset {
        let withBackButton: Bool
        var leftItem: NavigationItem?
        var rightItem: NavigationItem?
        var titleItem: NavigationItem?

        init(withBackButton: Bool = true, left: NavigationItem? = nil, title: NavigationItem? = nil, right: NavigationItem? = nil) {
            self.withBackButton = withBackButton
            self.leftItem = withBackButton ? NavigationBarButtonItem(icon: R.image.back_btn(), target: self, action: #selector(back)) : left
            self.rightItem = right
            self.titleItem = title
        }
    }

    var preset: Preset = Preset(withBackButton: true, left: nil, title: nil, right: nil)

    var navBarHeight: CGFloat = CollageNavigationController.preferredNavBarHeight {
        didSet {
            changeSafeAreaInset(top: navBarHeight)
            layout()
        }
    }

    var navBarItem: NavigationBarItem? {
        didSet {
            let withBackButton = navBarItem?.back != nil || navBarItem?.left == nil
            preset = Preset(withBackButton: withBackButton, left: navBarItem?.left, title: navBarItem?.titleItem, right: navBarItem?.right)
            setupForPreset(preset)
        }
    }

    var showBackButton: Bool = true {
        didSet {
            preset = Preset(withBackButton: showBackButton, left: navBarItem?.left, title: navBarItem?.titleItem, right: navBarItem?.right)
            
            setupForPreset(preset)
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

    private func setupForPreset(_ config: Preset) {
        navBar.leftItem = config.leftItem
        navBar.rightItem = config.rightItem
        navBar.titleItem = config.titleItem
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
    var back: NavigationBackButtonItem?
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

    private mutating func updateTitleItem(with title: String?) {
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

class NavigationBackButtonItem: NavigationBarButtonItem {
    let isBackButton: Bool = true
}
