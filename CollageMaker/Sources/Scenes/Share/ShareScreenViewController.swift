//
// Copyright © 2018 Dimasno1. All rights reserved. Product:  CollageMaker
//

import SnapKit
import UIKit
import Utils

protocol ShareScreenViewControllerDelegate: AnyObject {
    func shareScreenViewControllerDidCancel(_ controller: ShareScreenViewController)
}

class ShareScreenViewController: CollageBaseViewController {
    weak var delegate: ShareScreenViewControllerDelegate?

    var imageIsPrepared: Bool {
        return collageImage != nil
    }

    init(collage: Collage) {
        self.collage = collage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.collage = Collage()
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(thumbnailImageView)
        view.addSubview(shareButton)

        setup()
        makeConstraints()
        prepareHightResolutionImage()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setThumbnail()
    }

    private func setThumbnail() {
        if imageIsPrepared {
            thumbnailImageView.image = collageImage

            return
        }

        CollageRenderer.renderImage(from: collage, with: thumbnailImageView.bounds.size) { [weak self] image in
            self?.thumbnailImageView.image = image
        }
    }

    private func prepareHightResolutionImage() {
        CollageRenderer.renderImage(from: collage, with: CGSize(width: 1200, height: 1200)) { [weak self] image in
            self?.collageImage = image
        }
    }

    private func setup() {
        let left = NavigationBarButtonItem(icon: R.image.close_btn(), target: self, action: #selector(cancel))
        let title = NavigationBarLabelItem(title: "Share", color: .black, font: R.font.sfProDisplaySemibold(size: 19))

        navBarItem = NavigationBarItem(left: left, title: title)

        view.backgroundColor = .white
    }

    @objc private func cancel() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    private func makeConstraints() {
        thumbnailImageView.snp.makeConstraints { make in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
            }

            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(thumbnailImageView.snp.width)
        }

        shareButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(50)
        }

        shareButton.sizeToFit()
    }

    @objc private func share() {
        guard imageIsPrepared else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: collageImage.flatMap { [$0] } ?? [], applicationActivities: [])

        present(activityVC, animated: true, completion: nil)
    }

    @objc private func close() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private let shareButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.setTitle("Share", for: .normal)
        btn.setTitleColor(.brightLavender, for: .normal)
        btn.addTarget(self, action: #selector(share), for: .touchUpInside)
        btn.isHidden = false

        return btn
    }()

    private var collageImage: UIImage? {
        didSet {
            shareButton.isEnabled = true
        }
    }

    private var collage: Collage
    private let thumbnailImageView = UIImageView()

}
