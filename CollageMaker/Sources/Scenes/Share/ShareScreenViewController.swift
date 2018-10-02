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
        self.shareFooter = ShareScreenFooter(destinations: [.photos, .messages, .instagram, .other])

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(thumbnailImageView)
        view.addSubview(shareFooter)

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
        shareFooter.delegate = self

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

        shareFooter.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(thumbnailImageView.snp.bottom)
        }
    }

    @objc private func share() {
        guard imageIsPrepared else {
            return
        }
    }

    @objc private func close() {
        delegate?.shareScreenViewControllerDidCancel(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private var collage: Collage
    private var collageImage: UIImage?
    private let thumbnailImageView = UIImageView()
    private let shareFooter: ShareScreenFooter
}

extension ShareScreenViewController: ShareScreenFooterDelegate {
    func shareScreenFooter(_ footer: ShareScreenFooter, shareToolbar: ShareToolbar, didSelectDestination destination: ShareDestination) {
        print(destination)
    }

    func shareScreenFooter(_ footer: ShareScreenFooter, didTappedHashtag hashtag: String) {
        let alertController = UIAlertController(title: nil, message: "Hashtag copied to clipboard", preferredStyle: .alert)
        let completion = { alertController.dismiss(animated: true, completion: nil) }

        present(alertController, animated: true) { DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: completion) }
    }
}
