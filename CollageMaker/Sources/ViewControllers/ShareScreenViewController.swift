//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit
import Utils

protocol ShareScreenViewControllerDelegate: AnyObject {
    func shareScreenViewControllerShouldBeClosed(_ controller: ShareScreenViewController)
}

class ShareScreenViewController: CollageBaseViewController {
    weak var delegate: ShareScreenViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        makeConstraints()
    }

    func setCollagePreview(image: UIImage) {
        collageImageView.image = image
    }

    private func setup() {
        let left = NavigationBarButtonItem(title: "Back", font: R.font.sfProDisplaySemibold(size: 20), target: self, action: #selector(back))

        navBarItem = NavigationBarItem(left: left)

        view.backgroundColor = .white
        view.addSubview(collageImageView)
        view.addSubview(shareButton)
    }

    @objc private func back() {
        collageNavigationController?.pop()
    }

    private func makeConstraints() {
        collageImageView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collageImageView.snp.width)
        }

        shareButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(collageImageView.snp.bottom).offset(50)
        }

        shareButton.sizeToFit()
    }

    @objc private func share() {
        let activityVC = UIActivityViewController(activityItems: collageImageView.image.flatMap { [$0] } ?? [], applicationActivities: [])

        present(activityVC, animated: true, completion: nil)
    }

    @objc private func close() {
        delegate?.shareScreenViewControllerShouldBeClosed(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.setTitle("Share", for: .normal)
        btn.setTitleColor(.brightLavender, for: .normal)
        btn.addTarget(self, action: #selector(share), for: .touchUpInside)

        return btn
    }()

    private let collageImageView = UIImageView()
}
